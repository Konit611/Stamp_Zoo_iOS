//
//  StampCollection.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import Foundation
import SwiftData

// MARK: - Stamp Collection Model
@Model
final class StampCollection {
    @Attribute(.unique) var id: UUID
    var bingoNumber: Int
    var animalId: String
    var collectedAt: Date
    var qrCode: String
    var facilityName: String
    var userLatitude: Double?
    var userLongitude: Double?
    var isTestCollection: Bool
    
    // 현재 언어에 맞는 수집 시설명 반환
    var localizedFacilityName: String {
        if isTestCollection {
            return LocalizationHelper.shared.localizedText(
                korean: "테스트",
                english: "Test",
                japanese: "テスト",
                chinese: "测试"
            )
        }
        return facilityName
    }
    
    // 수집 시간을 포맷된 문자열로 반환
    var formattedCollectedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: collectedAt)
    }
    
    init(
        id: UUID = UUID(),
        bingoNumber: Int,
        animalId: String,
        qrCode: String,
        facilityName: String,
        userLatitude: Double? = nil,
        userLongitude: Double? = nil,
        isTestCollection: Bool = false
    ) {
        self.id = id
        self.bingoNumber = bingoNumber
        self.animalId = animalId
        self.qrCode = qrCode
        self.facilityName = facilityName
        self.userLatitude = userLatitude
        self.userLongitude = userLongitude
        self.isTestCollection = isTestCollection
        self.collectedAt = Date()
    }
}
