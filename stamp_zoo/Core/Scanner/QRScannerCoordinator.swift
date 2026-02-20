//
//  QRScannerCoordinator.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import AVFoundation
import UIKit
import AudioToolbox

enum QRScannerError: Error {
    case cameraNotAvailable
    case permissionDenied
    case scanningFailed
    case deviceNotSupported
    
    var localizedDescription: String {
        switch self {
        case .cameraNotAvailable:
            return LocalizationHelper.shared.localizedText(
                korean: "카메라를 사용할 수 없습니다.",
                english: "Camera not available.",
                japanese: "カメラを使用できません。",
                chinese: "无法使用相机。"
            )
        case .permissionDenied:
            return LocalizationHelper.shared.localizedText(
                korean: "카메라 접근 권한이 필요합니다.",
                english: "Camera permission required.",
                japanese: "カメラのアクセス許可が必要です。",
                chinese: "需要相机访问权限。"
            )
        case .scanningFailed:
            return LocalizationHelper.shared.localizedText(
                korean: "QR 코드 스캔에 실패했습니다.",
                english: "QR code scanning failed.",
                japanese: "QRコードのスキャンに失敗しました。",
                chinese: "QR码扫描失败。"
            )
        case .deviceNotSupported:
            return LocalizationHelper.shared.localizedText(
                korean: "이 기기는 QR 코드 스캔을 지원하지 않습니다.",
                english: "This device does not support QR code scanning.",
                japanese: "この機器はQRコードスキャンをサポートしていません。",
                chinese: "此设备不支持QR码扫描。"
            )
        }
    }
}

class QRScannerCoordinator: NSObject, ObservableObject {
    var onQRCodeScanned: ((String) -> Void)?
    var onError: ((QRScannerError) -> Void)?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var lastScannedCode: String?
    private var lastScanTime: Date?
    
    @Published var isScanning = false
    @Published var permissionGranted = false
    @Published var torchEnabled = false
    
    // 중복 스캔 방지를 위한 시간 간격 (초)
    private let scanCooldownInterval: TimeInterval = 2.0
    
    override init() {
        super.init()
        checkCameraPermission()
    }
    
    // MARK: - Camera Permission
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                self.permissionGranted = true
                print("Camera permission: Authorized")
            case .notDetermined:
                self.permissionGranted = false
                self.requestCameraPermission()
            case .denied, .restricted:
                self.permissionGranted = false
                print("Camera permission: Denied/Restricted")
            @unknown default:
                self.permissionGranted = false
            }
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
                print("Camera permission request result: \(granted)")
                if !granted {
                    self?.onError?(.permissionDenied)
                }
            }
        }
    }
    
    // MARK: - Capture Session Setup
    func setupCaptureSession() -> AVCaptureSession? {
        print("Setting up capture session...")
        print("Permission granted: \(permissionGranted)")
        
        guard permissionGranted else {
            print("Camera permission not granted")
            onError?(.permissionDenied)
            return nil
        }
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("No video capture device available")
            onError?(.cameraNotAvailable)
            return nil
        }
        
        print("Video capture device found: \(videoCaptureDevice)")
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = .high
            
            if captureSession?.canAddInput(videoInput) == true {
                captureSession?.addInput(videoInput)
                print("Video input added successfully")
            } else {
                print("Cannot add video input")
                onError?(.scanningFailed)
                return nil
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if captureSession?.canAddOutput(metadataOutput) == true {
                captureSession?.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
                print("Metadata output added successfully")
            } else {
                print("Cannot add metadata output")
                onError?(.scanningFailed)
                return nil
            }
            
            print("Capture session setup completed successfully")
            return captureSession
        } catch {
            print("Error setting up capture session: \(error)")
            onError?(.scanningFailed)
            return nil
        }
    }
    
    // MARK: - Scanning Control
    func startScanning() {
        print("Starting scanning...")
        guard let captureSession = captureSession else {
            print("No capture session available")
            return
        }
        
        print("Capture session exists, current running state: \(captureSession.isRunning)")
        
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                print("Starting capture session...")
                captureSession.startRunning()
                DispatchQueue.main.async {
                    self.isScanning = true
                    print("Capture session started, isScanning: \(self.isScanning)")
                }
            }
        } else {
            print("Capture session already running")
            isScanning = true
        }
    }
    
    func stopScanning() {
        guard let captureSession = captureSession else { return }
        
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.stopRunning()
                DispatchQueue.main.async {
                    self.isScanning = false
                }
            }
        }
    }
    
    // MARK: - Torch Control
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if torchEnabled {
                device.torchMode = .off
                torchEnabled = false
            } else {
                try device.setTorchModeOn(level: 1.0)
                torchEnabled = true
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    private func shouldProcessScan(for code: String) -> Bool {
        let now = Date()
        
        // 같은 코드를 연속으로 스캔하는 것을 방지
        if let lastCode = lastScannedCode,
           let lastTime = lastScanTime,
           lastCode == code,
           now.timeIntervalSince(lastTime) < scanCooldownInterval {
            return false
        }
        
        return true
    }
    
    private func processScan(code: String) {
        lastScannedCode = code
        lastScanTime = Date()
        
        // 햅틱 피드백
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // 시스템 사운드 (QR 스캔 성공)
        AudioServicesPlaySystemSound(1016)
        
        // 델리게이트에 결과 전달
        onQRCodeScanned?(code)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRScannerCoordinator: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        // 중복 스캔 방지
        guard shouldProcessScan(for: stringValue) else { return }
        
        // 스캔 처리
        processScan(code: stringValue)
    }
}
