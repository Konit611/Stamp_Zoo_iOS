//
//  BingoHomeViewModel.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI
import SwiftData
import Foundation

// MARK: - Bingo Stamp Item
struct BingoStamp {
    let animal: Animal?
    let position: Int
    let isCollected: Bool
}

@Observable
class BingoHomeViewModel {
    private var modelContext: ModelContext?
    private var allAnimals: [Animal] = []
    private var allBingoAnimals: [BingoAnimal] = []
    private var collectedStamps: [StampCollection] = []
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadAnimals()
        loadBingoAnimals()
        loadCollectedStamps()
        updateBingoStamps()
    }
    
    // MARK: - Computed Properties
    
    /// 캐시된 빙고 스탬프 배열 (0-8 인덱스)
    private(set) var bingoStamps: [BingoStamp] = []

    /// bingoStamps 캐시 갱신
    private func updateBingoStamps() {
        var stamps: [BingoStamp] = []
        for position in 0..<9 {
            let bingoNumber = position + 1
            let animal = getAnimal(for: bingoNumber)
            let isCollected = allBingoAnimals.contains { $0.bingoNumber == bingoNumber }
            stamps.append(BingoStamp(animal: animal, position: position, isCollected: isCollected))
        }
        bingoStamps = stamps
    }
    
    /// 빙고에 포함된 동물들
    var bingoAnimals: [Animal] {
        return allBingoAnimals.compactMap { bingoAnimal in
            getAnimal(by: bingoAnimal.animalId)
        }
    }
    
    /// 수집된 스탬프 개수
    var collectedStampsCount: Int {
        return bingoStamps.filter { $0.isCollected }.count
    }
    
    /// 전체 스탬프 개수
    var totalStampsCount: Int {
        return 9
    }
    
    /// 완성률 (퍼센트)
    var completionRate: Int {
        guard totalStampsCount > 0 else { return 0 }
        return Int((Double(collectedStampsCount) / Double(totalStampsCount)) * 100)
    }
    
    /// 빙고 완성 여부
    var isBingoComplete: Bool {
        return collectedStampsCount == totalStampsCount
    }
    
    // MARK: - Methods
    
    /// ModelContext 업데이트
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        loadAnimals()
        loadBingoAnimals()
        loadCollectedStamps()
        updateBingoStamps()
    }
    
    /// 동물 데이터 로드
    private func loadAnimals() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Animal>()
            allAnimals = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load animals: \(error)")
            allAnimals = []
        }
    }
    
    /// 빙고 동물 데이터 로드
    private func loadBingoAnimals() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<BingoAnimal>()
            allBingoAnimals = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load bingo animals: \(error)")
            allBingoAnimals = []
        }
    }
    
    /// 데이터 새로고침
    func refresh() {
        loadAnimals()
        loadBingoAnimals()
        loadCollectedStamps()
        updateBingoStamps()
    }
    
    /// 특정 위치의 스탬프 정보 가져오기
    func getStamp(at position: Int) -> BingoStamp? {
        guard position >= 0 && position < bingoStamps.count else { return nil }
        return bingoStamps[position]
    }
    
    /// 수집된 스탬프 데이터 로드
    private func loadCollectedStamps() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<StampCollection>()
            collectedStamps = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load collected stamps: \(error)")
            collectedStamps = []
        }
    }
    
    /// 특정 빙고 번호의 스탬프가 수집되었는지 확인 (BingoAnimal 기반 - 시즌 리셋 반영)
    func isStampCollected(bingoNumber: Int) -> Bool {
        return allBingoAnimals.contains { $0.bingoNumber == bingoNumber }
    }
    
    /// 수집된 스탬프 정보 가져오기
    func getCollectedStamp(bingoNumber: Int) -> StampCollection? {
        return collectedStamps.first { $0.bingoNumber == bingoNumber }
    }
    
    /// 모든 수집된 스탬프 가져오기 (최신순)
    var allCollectedStamps: [StampCollection] {
        return collectedStamps.sorted { $0.collectedAt > $1.collectedAt }
    }
    
    /// 빙고 번호로 동물 찾기
    private func getAnimal(for bingoNumber: Int) -> Animal? {
        guard let bingoAnimal = allBingoAnimals.first(where: { $0.bingoNumber == bingoNumber }) else {
            return nil
        }
        return getAnimal(by: bingoAnimal.animalId)
    }
    
    /// 동물 ID로 동물 찾기
    private func getAnimal(by animalId: String) -> Animal? {
        return allAnimals.first { $0.id.uuidString == animalId }
    }
}

