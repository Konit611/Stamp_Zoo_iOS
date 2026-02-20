//
//  BingoQRView.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI
import AVFoundation

struct BingoQRView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var qrCoordinator = QRScannerCoordinator()
    @StateObject private var locationService = LocationService()
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    
    @State private var qrValidationService: QRValidationService?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isScanning = false
    @State private var bingoHomeViewModel: BingoHomeViewModel?
    
    var body: some View {
        ZStack {
            // 배경 이미지 (원래대로)
            Image("qr_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // 상단 네비게이션 바 영역 (원래대로)
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // QR 코드 스캔 영역 (원래 디자인 + 카메라)
                VStack(spacing: 30) {
                    // QR 스캔 영역 (카메라 또는 검은색 박스)
                    ZStack {
                        if qrCoordinator.permissionGranted {
                            // 실제 카메라 뷰 (300x300 크기로 제한)
                            QRScannerView(coordinator: qrCoordinator)
                                .frame(width: 300, height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            // 권한이 없을 때는 검은색 박스
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black)
                                .frame(width: 300, height: 300)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isScanning ? Color.green : Color.white, lineWidth: 2)
                    )
                    
                    // 촬영 버튼 (원래대로)
                    Button(action: {
                        toggleScanning()
                    }) {
                        Text(localizationHelper.localizedText(
                            korean: isScanning ? "스캔 중지" : "스캔 시작",
                            english: isScanning ? "Stop Scanning" : "Start Scanning",
                            japanese: isScanning ? "スキャン停止" : "スキャン開始",
                            chinese: isScanning ? "停止扫描" : "开始扫描"
                        ))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isScanning ? Color.red : Color(red: 0.1, green: 0.2, blue: 0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                    .padding(.horizontal, 40)
                    .disabled(!qrCoordinator.permissionGranted)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            setupServices()
            locationService.requestLocationPermission()
            qrCoordinator.onQRCodeScanned = { code in
                isScanning = false
                processQRCode(code)
            }
            qrCoordinator.onError = { error in
                isScanning = false
                alertMessage = error.localizedDescription
                showingAlert = true
            }

            // 카메라 권한이 이미 승인되었다면 자동으로 스캔 시작
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if qrCoordinator.permissionGranted {
                    qrCoordinator.startScanning()
                    isScanning = true
                }
            }
        }
        .onDisappear {
            qrCoordinator.stopScanning()
            locationService.stopLocationUpdates()
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button(localizationHelper.localizedText(
                korean: "확인",
                english: "OK",
                japanese: "確認",
                chinese: "确认"
            )) {
                showingAlert = false
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func setupServices() {
        qrValidationService = QRValidationService(modelContext: modelContext, locationService: locationService)
        bingoHomeViewModel = BingoHomeViewModel(modelContext: modelContext)
        locationService.startLocationUpdates()
    }
    
    private func toggleScanning() {
        if isScanning {
            qrCoordinator.stopScanning()
            isScanning = false
        } else {
            qrCoordinator.startScanning()
            isScanning = true
        }
    }
    
    private func processQRCode(_ code: String) {
        guard let validationService = qrValidationService else { return }
        
        let result = validationService.validateQRCode(code)
        
        switch result {
        case .success(_, _):
            // 성공: 실제 스탬프 수집
            if validationService.collectStamp(result: result, qrCode: code) {
                bingoHomeViewModel?.refresh()
                alertMessage = result.localizedMessage
            } else {
                alertMessage = localizationHelper.localizedText(
                    korean: "스탬프 저장에 실패했습니다.",
                    english: "Failed to save stamp.",
                    japanese: "スタンプの保存に失敗しました。",
                    chinese: "邮票保存失败。"
                )
            }
            
        case .testSuccess(_):
            // 테스트 성공: 테스트 스탬프 수집
            if validationService.collectStamp(result: result, qrCode: code) {
                bingoHomeViewModel?.refresh()
                alertMessage = result.localizedMessage
            } else {
                alertMessage = localizationHelper.localizedText(
                    korean: "테스트 스탬프 저장에 실패했습니다.",
                    english: "Failed to save test stamp.",
                    japanese: "テストスタンプの保存に失敗しました。",
                    chinese: "测试邮票保存失败。"
                )
            }
            
        default:
            // 실패: 오류 메시지 표시
            alertMessage = result.localizedMessage
        }
        
        showingAlert = true
    }
}

#Preview {
    NavigationView {
        BingoQRView()
    }
} 
