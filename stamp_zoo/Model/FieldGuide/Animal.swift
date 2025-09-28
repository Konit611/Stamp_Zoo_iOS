//
//  Animal.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import Foundation
import SwiftData

// MARK: - Animal Model
@Model
final class Animal {
    @Attribute(.unique) var id: UUID
    
    // 다국어 지원 - 이름
    var nameKo: String  // 한국어
    var nameEn: String  // 영어
    var nameJa: String  // 일본어
    var nameZh: String  // 중국어
    
    // 다국어 지원 - 상세 설명
    var detailKo: String
    var detailEn: String
    var detailJa: String
    var detailZh: String
    
    var image: String
    var stampImage: String
    @Relationship(inverse: \Facility.animals)
    var facility: Facility

    // 현재 언어에 맞는 이름 반환
    var name: String {
        LocalizationHelper.shared.localizedText(
            korean: nameKo,
            english: nameEn,
            japanese: nameJa,
            chinese: nameZh
        )
    }
    
    // 현재 언어에 맞는 상세 설명 반환
    var detail: String {
        LocalizationHelper.shared.localizedText(
            korean: detailKo,
            english: detailEn,
            japanese: detailJa,
            chinese: detailZh
        )
    }

    init(
        id: UUID = UUID(),
        nameKo: String,
        nameEn: String,
        nameJa: String,
        nameZh: String,
        detailKo: String,
        detailEn: String,
        detailJa: String,
        detailZh: String,
        image: String,
        stampImage: String,
        facility: Facility
    ) {
        self.id = id
        self.nameKo = nameKo
        self.nameEn = nameEn
        self.nameJa = nameJa
        self.nameZh = nameZh
        self.detailKo = detailKo
        self.detailEn = detailEn
        self.detailJa = detailJa
        self.detailZh = detailZh
        self.image = image
        self.stampImage = stampImage
        self.facility = facility
    }
}


