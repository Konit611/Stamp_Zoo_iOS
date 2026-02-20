//
//  QRValidationService.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import Foundation
import SwiftData
import CoreLocation

enum QRValidationResult {
    case success(animal: Animal, facility: Facility)
    case testSuccess(animal: Animal)
    case alreadyCollected(animal: Animal)
    case invalidLocation(requiredFacility: Facility, distance: Double)
    case invalidCode
    case animalNotFound
    case locationUnavailable
    
    var isSuccess: Bool {
        switch self {
        case .success, .testSuccess:
            return true
        default:
            return false
        }
    }
    
    var localizedMessage: String {
        switch self {
        case .success(let animal, let facility):
            return LocalizationHelper.shared.localizedText(
                korean: "\(animal.name) 스탬프를 획득했습니다! (\(facility.name))",
                english: "Got \(animal.name) stamp! (\(facility.name))",
                japanese: "\(animal.name)のスタンプを獲得しました！(\(facility.name))",
                chinese: "获得了\(animal.name)邮票！(\(facility.name))"
            )
        case .testSuccess(let animal):
            return LocalizationHelper.shared.localizedText(
                korean: "[테스트] \(animal.name) 스탬프를 획득했습니다!",
                english: "[Test] Got \(animal.name) stamp!",
                japanese: "[テスト] \(animal.name)のスタンプを獲得しました！",
                chinese: "[测试] 获得了\(animal.name)邮票！"
            )
        case .alreadyCollected(let animal):
            return LocalizationHelper.shared.localizedText(
                korean: "\(animal.name) 스탬프는 이미 수집되었습니다",
                english: "\(animal.name) stamp already collected",
                japanese: "\(animal.name)のスタンプはすでに収集されています",
                chinese: "\(animal.name)邮票已收集"
            )
        case .invalidLocation(let facility, let distance):
            let distanceText = formatDistance(distance)
            return LocalizationHelper.shared.localizedText(
                korean: "\(facility.name) 근처에서만 스캔 가능합니다 (현재 거리: \(distanceText))",
                english: "Can only scan near \(facility.name) (current distance: \(distanceText))",
                japanese: "\(facility.name)の近くでのみスキャン可能です (現在の距離: \(distanceText))",
                chinese: "只能在\(facility.name)附近扫描 (当前距离: \(distanceText))"
            )
        case .invalidCode:
            return LocalizationHelper.shared.localizedText(
                korean: "유효하지 않은 QR 코드입니다",
                english: "Invalid QR code",
                japanese: "無効なQRコードです",
                chinese: "无效的QR码"
            )
        case .animalNotFound:
            return LocalizationHelper.shared.localizedText(
                korean: "해당 동물을 찾을 수 없습니다",
                english: "Animal not found",
                japanese: "該当する動物が見つかりません",
                chinese: "找不到该动物"
            )
        case .locationUnavailable:
            return LocalizationHelper.shared.localizedText(
                korean: "위치 정보를 사용할 수 없습니다. 위치 권한을 확인해주세요.",
                english: "Location unavailable. Please check location permissions.",
                japanese: "位置情報が利用できません。位置情報の許可を確認してください。",
                chinese: "位置信息不可用。请检查位置权限。"
            )
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0fm", distance)
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

class QRValidationService {
    private let modelContext: ModelContext
    private let locationService: LocationService
    
    init(modelContext: ModelContext, locationService: LocationService) {
        self.modelContext = modelContext
        self.locationService = locationService
    }
    
    /// QR 코드 검증 메인 함수
    func validateQRCode(_ code: String) -> QRValidationResult {
        // 1. QR 코드 형식 검증
        if code.hasPrefix("stamp_zoo://test/animal/") {
            return validateTestQRCode(code)
        } else if code.hasPrefix("stamp_zoo://animal/") {
            return validateAnimalQRCode(code)
        } else if code.hasPrefix("stamp_zoo://facility/") {
            return validateFacilityQRCode(code)
        } else {
            return .invalidCode
        }
    }
    
    /// 동물 UUID로 QR 코드 검증 (위치 검증 포함)
    private func validateAnimalQRCode(_ code: String) -> QRValidationResult {
        guard let animalUUID = extractAnimalUUID(from: code) else {
            return .invalidCode
        }
        
        guard let animal = findAnimal(by: animalUUID) else {
            return .animalNotFound
        }
        
        if isAnimalAlreadyCollected(animalId: animalUUID.uuidString) {
            return .alreadyCollected(animal: animal)
        }
        
        // 위치 검증 추가
        guard locationService.hasLocationPermission else {
            return .locationUnavailable
        }
        
        guard locationService.currentLocation != nil else {
            return .locationUnavailable
        }
        
        let facility = animal.facility
        if !locationService.isUserInFacilityRange(facility) {
            let distance = locationService.distanceToFacility(facility) ?? 0
            return .invalidLocation(requiredFacility: facility, distance: distance)
        }
        
        return .success(animal: animal, facility: facility)
    }
    
    /// 테스트용 QR 코드 검증 (위치 제한 없음) - UUID 기반
    private func validateTestQRCode(_ code: String) -> QRValidationResult {
        // stamp_zoo://test/animal/{uuid} 형식에서 UUID 추출
        let testPrefix = "stamp_zoo://test/animal/"
        guard code.hasPrefix(testPrefix) else {
            return .invalidCode
        }
        
        let uuidString = String(code.dropFirst(testPrefix.count))
        guard let animalUUID = UUID(uuidString: uuidString) else {
            return .invalidCode
        }
        
        guard let animal = findAnimal(by: animalUUID) else {
            return .animalNotFound
        }
        
        if isAnimalAlreadyCollected(animalId: animalUUID.uuidString) {
            return .alreadyCollected(animal: animal)
        }
        
        return .testSuccess(animal: animal)
    }
    
    /// 시설용 QR 코드 검증 (위치 제한 있음)
    private func validateFacilityQRCode(_ code: String) -> QRValidationResult {
        // QR 코드 파싱: stamp_zoo://facility/{facilityId}/animal/{animalIndex}
        let components = code.replacingOccurrences(of: "stamp_zoo://facility/", with: "").split(separator: "/")

        guard components.count == 3,
              !components[0].isEmpty,
              components[1] == "animal",
              let animalIndex = Int(components[2]) else {
            return .invalidCode
        }

        let facilityId = String(components[0])

        guard let facility = findFacility(by: facilityId) else {
            return .invalidCode
        }

        // 시설의 동물 목록에서 인덱스로 동물 찾기
        guard let animals = facility.animals,
              animalIndex >= 0 && animalIndex < animals.count else {
            return .animalNotFound
        }

        let animal = animals[animalIndex]

        if isAnimalAlreadyCollected(animalId: animal.id.uuidString) {
            return .alreadyCollected(animal: animal)
        }

        // 위치 검증
        guard locationService.hasLocationPermission else {
            return .locationUnavailable
        }

        guard locationService.currentLocation != nil else {
            return .locationUnavailable
        }

        if !locationService.isUserInFacilityRange(facility) {
            let distance = locationService.distanceToFacility(facility) ?? 0
            return .invalidLocation(requiredFacility: facility, distance: distance)
        }

        return .success(animal: animal, facility: facility)
    }
    
    /// 스탬프 수집 처리
    func collectStamp(result: QRValidationResult, qrCode: String) -> Bool {
        guard result.isSuccess else { return false }
        
        let animal: Animal
        let facilityName: String
        let isTestCollection: Bool
        
        switch result {
        case .success(let resultAnimal, let facility):
            animal = resultAnimal
            facilityName = facility.name
            isTestCollection = false
        case .testSuccess(let resultAnimal):
            animal = resultAnimal
            facilityName = "Test"
            isTestCollection = true
        default:
            return false
        }
        
        // 다음 빙고 번호 결정 (1-9)
        let nextBingoNumber = getNextBingoNumber()
        guard nextBingoNumber <= 9 else {
            print("빙고가 이미 완성되었습니다.")
            return false
        }
        
        // BingoAnimal 동적 생성
        let bingoAnimal = BingoAnimal(
            bingoNumber: nextBingoNumber,
            animalId: animal.id.uuidString,
            qrCode: qrCode
        )
        modelContext.insert(bingoAnimal)
        
        let userLocation = locationService.currentLocation
        let stampCollection = StampCollection(
            bingoNumber: nextBingoNumber,
            animalId: animal.id.uuidString,
            qrCode: qrCode,
            facilityName: facilityName,
            userLatitude: userLocation?.coordinate.latitude,
            userLongitude: userLocation?.coordinate.longitude,
            isTestCollection: isTestCollection
        )
        
        modelContext.insert(stampCollection)
        
        do {
            try modelContext.save()
            return true
        } catch {
            print("Failed to save stamp collection: \(error)")
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    /// QR 코드에서 Animal UUID 추출 (stamp_zoo://animal/{uuid})
    private func extractAnimalUUID(from code: String) -> UUID? {
        guard let lastComponent = code.split(separator: "/").last else { return nil }
        return UUID(uuidString: String(lastComponent))
    }
    
    /// UUID로 동물 찾기
    private func findAnimal(by uuid: UUID) -> Animal? {
        let descriptor = FetchDescriptor<Animal>(
            predicate: #Predicate { $0.id == uuid }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    /// Animal이 이미 수집되었는지 확인 (BingoAnimal 테이블에서)
    private func isAnimalAlreadyCollected(animalId: String) -> Bool {
        let descriptor = FetchDescriptor<BingoAnimal>(
            predicate: #Predicate { $0.animalId == animalId }
        )
        let existing = try? modelContext.fetch(descriptor)
        return !(existing?.isEmpty ?? true)
    }
    
    /// 시설 ID로 시설 찾기
    private func findFacility(by facilityId: String) -> Facility? {
        let descriptor = FetchDescriptor<Facility>(
            predicate: #Predicate<Facility> { facility in
                facility.facilityId == facilityId
            }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    /// 해당 빙고 번호가 이미 수집되었는지 확인
    private func isAlreadyCollected(bingoNumber: Int) -> Bool {
        let descriptor = FetchDescriptor<StampCollection>(
            predicate: #Predicate<StampCollection> { collection in
                collection.bingoNumber == bingoNumber
            }
        )
        let collections = try? modelContext.fetch(descriptor)
        return !(collections?.isEmpty ?? true)
    }
    
    /// 모든 수집된 스탬프 가져오기
    func getAllCollectedStamps() -> [StampCollection] {
        let descriptor = FetchDescriptor<StampCollection>(
            sortBy: [SortDescriptor(\.collectedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// 특정 빙고 번호가 수집되었는지 확인
    func isStampCollected(bingoNumber: Int) -> Bool {
        return isAlreadyCollected(bingoNumber: bingoNumber)
    }
    
    /// Animal에 대응하는 빙고 번호 찾기
    private func getBingoNumber(for animal: Animal) -> Int? {
        let animalIdString = animal.id.uuidString
        let descriptor = FetchDescriptor<BingoAnimal>(
            predicate: #Predicate { $0.animalId == animalIdString }
        )
        
        guard let bingoAnimal = try? modelContext.fetch(descriptor).first else {
            return nil
        }
        
        return bingoAnimal.bingoNumber
    }
    
    /// 1-9 중에서 사용되지 않은 랜덤 빙고 번호 가져오기
    private func getNextBingoNumber() -> Int {
        // 현재 사용 중인 빙고 번호들 조회
        let descriptor = FetchDescriptor<BingoAnimal>()
        let existingBingoAnimals = (try? modelContext.fetch(descriptor)) ?? []
        let usedNumbers = Set(existingBingoAnimals.map { $0.bingoNumber })
        
        // 1-9 중에서 사용되지 않은 번호들
        let availableNumbers = Array(1...9).filter { !usedNumbers.contains($0) }
        
        guard !availableNumbers.isEmpty else {
            return 10 // 빙고 완성 (9개 초과)
        }
        
        // 사용 가능한 번호 중에서 랜덤 선택
        return availableNumbers.randomElement() ?? 10
    }
}
