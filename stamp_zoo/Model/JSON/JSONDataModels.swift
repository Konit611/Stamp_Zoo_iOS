//
//  JSONDataModels.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import Foundation

// MARK: - JSON Data Models

/// JSON 데이터 파일의 메타데이터
struct DataFileMetadata: Codable {
    let version: String
    let season: String
    let lastUpdated: String
    let description: String
    let dataCount: Int

    enum CodingKeys: String, CodingKey {
        case version
        case season
        case lastUpdated = "last_updated"
        case description
        case dataCount = "data_count"
    }
}

/// JSON 파일 전체 구조
struct ZooDataFile: Codable {
    let metadata: DataFileMetadata
    let facilities: [FacilityJSON]
    let animals: [AnimalJSON]
    let bingoCards: [BingoCardJSON]?

    enum CodingKeys: String, CodingKey {
        case metadata
        case facilities
        case animals
        case bingoCards
    }
}

/// 시설 JSON 모델
struct FacilityJSON: Codable, Identifiable {
    let id: String
    let facilityId: String
    let nameKo: String
    let nameEn: String
    let nameJa: String
    let nameZh: String
    let type: String
    let locationKo: String?
    let locationEn: String?
    let locationJa: String?
    let locationZh: String?
    let image: String
    let logoImage: String
    let mapImage: String
    let mapLink: String
    let detailKo: String
    let detailEn: String
    let detailJa: String
    let detailZh: String
    let latitude: Double
    let longitude: Double
    let validationRadius: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case facilityId = "facility_id"
        case nameKo = "name_ko"
        case nameEn = "name_en"
        case nameJa = "name_ja"
        case nameZh = "name_zh"
        case type
        case locationKo = "location_ko"
        case locationEn = "location_en"
        case locationJa = "location_ja"
        case locationZh = "location_zh"
        case image
        case logoImage = "logo_image"
        case mapImage = "map_image"
        case mapLink = "map_link"
        case detailKo = "detail_ko"
        case detailEn = "detail_en"
        case detailJa = "detail_ja"
        case detailZh = "detail_zh"
        case latitude
        case longitude
        case validationRadius = "validation_radius"
    }
}

/// 동물 JSON 모델
struct AnimalJSON: Codable, Identifiable {
    let id: String
    let nameKo: String
    let nameEn: String
    let nameJa: String
    let nameZh: String
    let detailKo: String
    let detailEn: String
    let detailJa: String
    let detailZh: String
    let image: String
    let stampImage: String
    let facilityId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameKo = "name_ko"
        case nameEn = "name_en"
        case nameJa = "name_ja"
        case nameZh = "name_zh"
        case detailKo = "detail_ko"
        case detailEn = "detail_en"
        case detailJa = "detail_ja"
        case detailZh = "detail_zh"
        case image
        case stampImage = "stamp_image"
        case facilityId = "facility_id"
    }
}

/// 빙고 카드 JSON 모델
struct BingoCardJSON: Codable, Identifiable {
    let id: String
    let nameKo: String
    let nameEn: String
    let nameJa: String
    let nameZh: String
    let descriptionKo: String
    let descriptionEn: String
    let descriptionJa: String
    let descriptionZh: String
    let gridSize: Int // 3x3 = 9
    let isActive: Bool
    let displayOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameKo = "name_ko"
        case nameEn = "name_en"
        case nameJa = "name_ja"
        case nameZh = "name_zh"
        case descriptionKo = "description_ko"
        case descriptionEn = "description_en"
        case descriptionJa = "description_ja"
        case descriptionZh = "description_zh"
        case gridSize = "grid_size"
        case isActive = "is_active"
        case displayOrder = "display_order"
    }
}

// MARK: - Extensions for Model Conversion

extension FacilityJSON {
    /// JSON에서 SwiftData Facility 모델로 변환
    func toFacility() -> Facility {
        return Facility(
            nameKo: nameKo,
            nameEn: nameEn,
            nameJa: nameJa,
            nameZh: nameZh,
            type: FacilityType(rawValue: type) ?? .zoo,
            locationKo: locationKo,
            locationEn: locationEn,
            locationJa: locationJa,
            locationZh: locationZh,
            image: image,
            logoImage: logoImage,
            mapImage: mapImage,
            mapLink: mapLink,
            detailKo: detailKo,
            detailEn: detailEn,
            detailJa: detailJa,
            detailZh: detailZh,
            latitude: latitude,
            longitude: longitude,
            validationRadius: validationRadius,
            facilityId: facilityId
        )
    }
}

extension Facility {
    /// SwiftData Facility 모델에서 JSON으로 변환
    func toJSON() -> FacilityJSON {
        return FacilityJSON(
            id: id.uuidString,
            facilityId: facilityId,
            nameKo: nameKo,
            nameEn: nameEn,
            nameJa: nameJa,
            nameZh: nameZh,
            type: type.rawValue,
            locationKo: locationKo,
            locationEn: locationEn,
            locationJa: locationJa,
            locationZh: locationZh,
            image: image,
            logoImage: logoImage,
            mapImage: mapImage,
            mapLink: mapLink,
            detailKo: detailKo,
            detailEn: detailEn,
            detailJa: detailJa,
            detailZh: detailZh,
            latitude: latitude,
            longitude: longitude,
            validationRadius: validationRadius
        )
    }
}

extension AnimalJSON {
    /// JSON에서 SwiftData Animal 모델로 변환 (Facility는 별도로 찾아서 설정)
    func toAnimal(facility: Facility) -> Animal {
        return Animal(
            id: UUID(uuidString: id) ?? UUID(),
            nameKo: nameKo,
            nameEn: nameEn,
            nameJa: nameJa,
            nameZh: nameZh,
            detailKo: detailKo,
            detailEn: detailEn,
            detailJa: detailJa,
            detailZh: detailZh,
            image: image,
            stampImage: stampImage,
            facility: facility
        )
    }
}

extension Animal {
    /// SwiftData Animal 모델에서 JSON으로 변환
    func toJSON() -> AnimalJSON {
        return AnimalJSON(
            id: id.uuidString,
            nameKo: nameKo,
            nameEn: nameEn,
            nameJa: nameJa,
            nameZh: nameZh,
            detailKo: detailKo,
            detailEn: detailEn,
            detailJa: detailJa,
            detailZh: detailZh,
            image: image,
            stampImage: stampImage,
            facilityId: facility.facilityId
        )
    }
}

// MARK: - Bingo Extensions

extension BingoCardJSON {
    /// JSON에서 SwiftData BingoCard 모델로 변환
    func toBingoCard() -> BingoCard {
        return BingoCard(
            nameKo: nameKo,
            nameEn: nameEn,
            nameJa: nameJa,
            nameZh: nameZh,
            descriptionKo: descriptionKo,
            descriptionEn: descriptionEn,
            descriptionJa: descriptionJa,
            descriptionZh: descriptionZh,
            cardId: id,
            gridSize: gridSize,
            isActive: isActive,
            displayOrder: displayOrder
        )
    }
}