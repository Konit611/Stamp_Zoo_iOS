//
//  Facilities.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import Foundation
import SwiftData

// MARK: - Facility Type Enum
enum FacilityType: String, CaseIterable, Codable {
    case zoo = "zoo"
    case aquarium = "aquarium"
    
    var displayName: String {
        switch self {
        case .zoo:
            return LocalizationHelper.shared.localizedText(
                korean: "동물원",
                english: "Zoo",
                japanese: "動物園",
                chinese: "动物园"
            )
        case .aquarium:
            return LocalizationHelper.shared.localizedText(
                korean: "수족관",
                english: "Aquarium",
                japanese: "水族館",
                chinese: "水族馆"
            )
        }
    }
}

@Model
final class Facility {
    @Attribute(.unique) var id: UUID
    
    // 다국어 지원 - 시설명
    var nameKo: String
    var nameEn: String
    var nameJa: String
    var nameZh: String
    
    var type: FacilityType
    
    // 다국어 지원 - 위치
    var locationKo: String?
    var locationEn: String?
    var locationJa: String?
    var locationZh: String?
    
    var image: String
    var logoImage: String
    var mapImage: String
    var mapLink: String
    
    // 다국어 지원 - 상세 설명
    var detailKo: String
    var detailEn: String
    var detailJa: String
    var detailZh: String

    @Relationship(deleteRule: .cascade)
    var animals: [Animal]?
    
    // GPS 위치 정보
    var latitude: Double
    var longitude: Double
    var validationRadius: Double  // 유효 범위 (미터)
    var facilityId: String        // 시설 고유 ID
    
    // 현재 언어에 맞는 시설명 반환
    var name: String {
        LocalizationHelper.shared.localizedText(
            korean: nameKo,
            english: nameEn,
            japanese: nameJa,
            chinese: nameZh
        )
    }
    
    // 현재 언어에 맞는 위치 반환
    var location: String? {
        guard let locationKo = locationKo else { return nil }
        
        return LocalizationHelper.shared.localizedText(
            korean: locationKo,
            english: locationEn ?? locationKo,
            japanese: locationJa ?? locationKo,
            chinese: locationZh ?? locationKo
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
        type: FacilityType,
        locationKo: String? = nil,
        locationEn: String? = nil,
        locationJa: String? = nil,
        locationZh: String? = nil,
        image: String,
        logoImage: String,
        mapImage: String,
        mapLink: String,
        detailKo: String,
        detailEn: String,
        detailJa: String,
        detailZh: String,
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        validationRadius: Double = 500.0,
        facilityId: String,
        animals: [Animal]? = nil
    ) {
        self.id = id
        self.nameKo = nameKo
        self.nameEn = nameEn
        self.nameJa = nameJa
        self.nameZh = nameZh
        self.type = type
        self.locationKo = locationKo
        self.locationEn = locationEn
        self.locationJa = locationJa
        self.locationZh = locationZh
        self.image = image
        self.logoImage = logoImage
        self.mapImage = mapImage
        self.mapLink = mapLink
        self.detailKo = detailKo
        self.detailEn = detailEn
        self.detailJa = detailJa
        self.detailZh = detailZh
        self.latitude = latitude
        self.longitude = longitude
        self.validationRadius = validationRadius
        self.facilityId = facilityId
        self.animals = animals
    }
}
