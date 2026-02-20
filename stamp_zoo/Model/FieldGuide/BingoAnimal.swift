//
//  BingoAnimal.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import Foundation
import SwiftData

// MARK: - Bingo Animal Model (동적 생성)
@Model
final class BingoAnimal {
    @Attribute(.unique) var id: UUID
    
    var bingoNumber: Int // 1-9 (QR 스캔 순서대로 부여)
    var animalId: String // Animal UUID
    var collectedAt: Date // 수집된 시간
    var qrCode: String // 스캔한 QR 코드
    
    init(
        id: UUID = UUID(),
        bingoNumber: Int,
        animalId: String,
        collectedAt: Date = Date(),
        qrCode: String
    ) {
        self.id = id
        self.bingoNumber = bingoNumber
        self.animalId = animalId
        self.collectedAt = collectedAt
        self.qrCode = qrCode
    }
}

// MARK: - Bingo Card Model
@Model
final class BingoCard {
    @Attribute(.unique) var id: UUID
    
    // 다국어 지원 - 빙고 카드명
    var nameKo: String
    var nameEn: String
    var nameJa: String
    var nameZh: String
    
    // 다국어 지원 - 설명
    var descriptionKo: String
    var descriptionEn: String
    var descriptionJa: String
    var descriptionZh: String
    
    var cardId: String // JSON에서의 고유 ID
    var gridSize: Int // 3x3 = 9
    var isActive: Bool
    var displayOrder: Int
    
    // 현재 언어에 맞는 빙고 카드명 반환
    var name: String {
        LocalizationHelper.shared.localizedText(
            korean: nameKo,
            english: nameEn,
            japanese: nameJa,
            chinese: nameZh
        )
    }
    
    // 현재 언어에 맞는 설명 반환
    var localizedDescription: String {
        LocalizationHelper.shared.localizedText(
            korean: descriptionKo,
            english: descriptionEn,
            japanese: descriptionJa,
            chinese: descriptionZh
        )
    }
    
    init(
        id: UUID = UUID(),
        nameKo: String,
        nameEn: String,
        nameJa: String,
        nameZh: String,
        descriptionKo: String,
        descriptionEn: String,
        descriptionJa: String,
        descriptionZh: String,
        cardId: String,
        gridSize: Int = 9,
        isActive: Bool = true,
        displayOrder: Int = 0
    ) {
        self.id = id
        self.nameKo = nameKo
        self.nameEn = nameEn
        self.nameJa = nameJa
        self.nameZh = nameZh
        self.descriptionKo = descriptionKo
        self.descriptionEn = descriptionEn
        self.descriptionJa = descriptionJa
        self.descriptionZh = descriptionZh
        self.cardId = cardId
        self.gridSize = gridSize
        self.isActive = isActive
        self.displayOrder = displayOrder
    }
}

// MARK: - Bingo Extensions

extension BingoCard {
    /// 전체 수집된 동물 개수 반환 (BingoAnimal 테이블 기준)
    func collectedAnimalsCount(from context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<BingoAnimal>()
        let bingoAnimals = (try? context.fetch(descriptor)) ?? []
        return bingoAnimals.count
    }
    
    /// 빙고 완성 여부 확인
    func isCompleted(from context: ModelContext) -> Bool {
        return collectedAnimalsCount(from: context) >= gridSize
    }
    
    /// 빙고 진행률 (0.0 ~ 1.0)
    func completionRate(from context: ModelContext) -> Double {
        guard gridSize > 0 else { return 0.0 }
        let collected = min(collectedAnimalsCount(from: context), gridSize)
        return Double(collected) / Double(gridSize)
    }
}
