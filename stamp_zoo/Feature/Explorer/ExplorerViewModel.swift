//
//  ExplorerViewModel.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI
import SwiftData
import Foundation

// MARK: - Facility Card Data
struct FacilityCard {
    let facility: Facility
    let isVisited: Bool
    let isZoo: Bool
    
    var title: String { facility.name }
    var location: String { 
        facility.location ?? LocalizationHelper.shared.localizedText(
            korean: "위치 정보 없음",
            english: "No Location Info",
            japanese: "位置情報なし",
            chinese: "无位置信息"
        )
    }
    var imageName: String { facility.image }
    var logoImageName: String { facility.logoImage }
}

@Observable
class ExplorerViewModel {
    private var modelContext: ModelContext?
    private var allFacilities: [Facility] = []
    private var bingoAnimals: [BingoAnimal] = []
    private var stampCollections: [StampCollection] = []
    private var localizationHelper = LocalizationHelper.shared
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadFacilities()
        loadBingoAnimals()
        loadStampCollections()
    }
    
    // MARK: - Computed Properties
    
    /// 모든 시설 카드 데이터
    var facilityCards: [FacilityCard] {
        return allFacilities.map { facility in
            // 방문 여부는 해당 시설의 동물이 하나라도 수집되었는지로 판단
            let isVisited = hasAnyCollectedAnimal(in: facility)
            let isZoo = facility.type == .zoo
            return FacilityCard(facility: facility, isVisited: isVisited, isZoo: isZoo)
        }
    }
    
    /// 카테고리별 필터링된 시설들
    func filteredFacilities(for category: ExplorerView.Category) -> [FacilityCard] {
        switch category {
        case .all:
            return facilityCards
        case .zoo:
            return facilityCards.filter { $0.facility.type == .zoo }
        case .aquarium:
            return facilityCards.filter { $0.facility.type == .aquarium }
        }
    }
    
    // MARK: - Methods
    
    /// ModelContext 업데이트
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        loadFacilities()
        loadBingoAnimals()
        loadStampCollections()
    }
    
    /// 시설 데이터 로드
    private func loadFacilities() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Facility>()
            allFacilities = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load facilities: \(error)")
            allFacilities = []
        }
    }
    
    /// 데이터 새로고침
    func refresh() {
        loadFacilities()
        loadBingoAnimals()
        loadStampCollections()
    }
    
    /// 빙고 동물 데이터 로드
    private func loadBingoAnimals() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<BingoAnimal>()
            bingoAnimals = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load bingo animals: \(error)")
            bingoAnimals = []
        }
    }
    
    /// 스탬프 수집 데이터 로드
    private func loadStampCollections() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<StampCollection>()
            stampCollections = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load stamp collections: \(error)")
            stampCollections = []
        }
    }
    
    /// 해당 시설에 수집된 동물이 있는지 확인 (StampCollection 기반 - 영구 기록)
    private func hasAnyCollectedAnimal(in facility: Facility) -> Bool {
        guard let animals = facility.animals else { return false }

        let collectedAnimalIds = Set(stampCollections.map { $0.animalId })

        return animals.contains { animal in
            collectedAnimalIds.contains(animal.id.uuidString)
        }
    }
    
    /// 시설의 위치 정보 가져오기
    func getSubtitle(for facility: Facility) -> String {
        return facility.location ?? LocalizationHelper.shared.localizedText(
            korean: "위치 정보 없음",
            english: "No Location Info",
            japanese: "位置情報なし",
            chinese: "无位置信息"
        )
    }
}

