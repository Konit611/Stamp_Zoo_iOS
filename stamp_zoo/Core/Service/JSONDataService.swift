//
//  JSONDataService.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import Foundation
import SwiftData

/// JSON 파일을 통한 동적 데이터 관리 서비스
class JSONDataService {
    static let shared = JSONDataService()
    
    private let userDefaults = UserDefaults.standard
    private let lastUpdateKey = "zoo_data_last_update_date"
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 앱 시작 시 데이터 업데이트 확인 및 로드
    static func loadDataIfNeeded(in container: ModelContainer) async {
        let context = ModelContext(container)
        
        // 기존 데이터가 있는지 확인
        let hasExistingData = await hasAnyData(in: context)
        
        if !hasExistingData {
            // 데이터가 없으면 최신 JSON 파일 로드
            await loadLatestJSONData(in: context)
        } else {
            // 데이터가 있으면 업데이트 확인
            await checkAndUpdateData(in: context)
        }
    }
    

    
    // MARK: - Private Methods
    
    /// 기존 데이터가 있는지 확인
    private static func hasAnyData(in context: ModelContext) async -> Bool {
        let animalDescriptor = FetchDescriptor<Animal>()
        let facilityDescriptor = FetchDescriptor<Facility>()
        
        do {
            let animals = try context.fetch(animalDescriptor)
            let facilities = try context.fetch(facilityDescriptor)
            return !animals.isEmpty && !facilities.isEmpty
        } catch {
            print("데이터 확인 중 오류: \(error)")
            return false
        }
    }
    
    /// 새로운 업데이트가 있는지 확인하고 데이터 업데이트
    private static func checkAndUpdateData(in context: ModelContext) async {
        print("🔍 업데이트 확인 중...")
        guard let latestDataFile = getLatestJSONFile() else {
            print("사용 가능한 JSON 파일이 없습니다.")
            return
        }
        
        // JSON 내부의 last_updated 값과 refresh 신호 확인
        guard let jsonMetadata = getJSONMetadata(from: latestDataFile) else {
            print("JSON 메타데이터를 읽을 수 없습니다.")
            return
        }
        
        let jsonLastUpdated = jsonMetadata.lastUpdated
        let refreshBingoAnimals = jsonMetadata.refreshBingoAnimals
        let storedLastUpdate = shared.userDefaults.string(forKey: shared.lastUpdateKey) ?? ""
        let latestFileDate = extractDateFromFileName(latestDataFile)
        
        print("📅 JSON 파일명 날짜: \(latestFileDate)")
        print("📅 JSON last_updated: \(jsonLastUpdated)")
        print("📅 저장된 마지막 업데이트: \(storedLastUpdate)")
        print("🔄 refresh_bingo_animals: \(refreshBingoAnimals)")
        
        // 업데이트 조건: 1) 새로운 날짜 또는 2) refresh 신호가 true
        let needsUpdate = jsonLastUpdated > storedLastUpdate || refreshBingoAnimals
        
        if needsUpdate {
            if refreshBingoAnimals {
                print("🚀 강제 업데이트: refresh_bingo_animals = true")
            } else {
                print("🆕 새로운 데이터 업데이트 발견: \(jsonLastUpdated)")
            }
            await loadJSONData(from: latestDataFile, in: context)
            shared.userDefaults.set(jsonLastUpdated, forKey: shared.lastUpdateKey)
        } else {
            print("✅ 데이터가 최신 상태입니다.")
        }
    }
    
    /// 최신 JSON 파일 로드
    private static func loadLatestJSONData(in context: ModelContext) async {
        guard let latestDataFile = getLatestJSONFile() else {
            print("JSON 파일을 찾을 수 없습니다. 앱 번들에 JSON 파일을 추가해주세요.")
            return
        }
        
        await loadJSONData(from: latestDataFile, in: context)
        
        let fileDate = extractDateFromFileName(latestDataFile)
        UserDefaults.standard.set(fileDate, forKey: shared.lastUpdateKey)
    }
    
    /// 특정 JSON 파일에서 데이터 로드
    private static func loadJSONData(from fileName: String, in context: ModelContext) async {
        guard let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            print("JSON 파일을 찾을 수 없습니다: \(fileName)")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let zooData = try JSONDecoder().decode(ZooDataFile.self, from: data)
            
            // 기존 데이터 삭제
            await clearExistingData(in: context)
            
            // 새로운 데이터 저장
            await saveJSONDataToSwiftData(zooData, in: context)
            
            print("데이터 로드 완료: \(zooData.metadata.description)")
            print("시설 \(zooData.facilities.count)개, 동물 \(zooData.animals.count)개 로드됨")
            
        } catch {
            print("JSON 데이터 로드 실패: \(error)")
        }
    }
    
    /// 기존 동물원 데이터 삭제 (스탬프 수집 데이터는 보존)
    private static func clearExistingData(in context: ModelContext) async {
        do {
            // 1. 먼저 관계가 있는 Animal 데이터 삭제 (Facility 참조 때문에 먼저 삭제)
            let animalDescriptor = FetchDescriptor<Animal>()
            let animals = try context.fetch(animalDescriptor)
            for animal in animals {
                context.delete(animal)
            }
            
            // 2. 빙고 카드 데이터 삭제 (새 빙고로 교체)
            let bingoCardDescriptor = FetchDescriptor<BingoCard>()
            let bingoCards = try context.fetch(bingoCardDescriptor)
            for bingoCard in bingoCards {
                context.delete(bingoCard)
            }
            
            // 3. 중간 저장 (관계 정리)
            try context.save()
            
            // 4. 마지막으로 Facility 데이터 삭제
            let facilityDescriptor = FetchDescriptor<Facility>()
            let facilities = try context.fetch(facilityDescriptor)
            for facility in facilities {
                context.delete(facility)
            }
            
            // 주의: BingoAnimal과 StampCollection은 여기서 삭제하지 않음
            // - StampCollection: Field Guide 수집 기록 (영구 보존)
            // - BingoAnimal: Bingo 진행 상태 (refresh 신호 시에만 초기화)
            
            try context.save()
            print("기존 동물원 데이터 삭제 완료 (스탬프 수집 데이터는 보존)")
        } catch {
            print("기존 데이터 삭제 실패: \(error)")
        }
    }
    
    /// JSON 데이터를 SwiftData에 저장
    private static func saveJSONDataToSwiftData(_ zooData: ZooDataFile, in context: ModelContext) async {
        do {
            // 시설 먼저 저장
            var facilityMap: [String: Facility] = [:]
            
            for facilityJSON in zooData.facilities {
                let facility = facilityJSON.toFacility()
                context.insert(facility)
                facilityMap[facilityJSON.facilityId] = facility
            }
            
            // 동물 저장
            for animalJSON in zooData.animals {
                guard let facility = facilityMap[animalJSON.facilityId] else {
                    print("시설을 찾을 수 없습니다: \(animalJSON.facilityId)")
                    continue
                }
                
                let animal = animalJSON.toAnimal(facility: facility)
                context.insert(animal)
            }
            
            // 빙고 카드 저장
            if let bingoCardsJSON = zooData.bingoCards {
                for bingoCardJSON in bingoCardsJSON {
                    let bingoCard = bingoCardJSON.toBingoCard()
                    context.insert(bingoCard)
                }
            }
            
            // refresh 신호에 따라 새 시즌 시작 (BingoAnimal만 초기화)
            print("🔍 refreshBingoAnimals 값: \(zooData.refreshBingoAnimals ?? false)")
            if zooData.refreshBingoAnimals == true {
                print("🚀 새 시즌 시작 - 빙고 게임 초기화 (새로운 빙고 시작)")
                await clearBingoAnimals(in: context)
                print("✅ 새 시즌 시작: 빙고 게임(BingoAnimal)이 초기화되었습니다.")
                print("📝 StampCollection은 보존됨 (Field Guide 수집 기록 유지)")
            } else {
                print("⏸️ refresh 신호 없음 - 기존 수집 데이터 유지")
            }
            
            try context.save()
            print("JSON 데이터 저장 완료")
        } catch {
            print("JSON 데이터 저장 실패: \(error)")
        }
    }
    
    /// 번들에서 사용 가능한 모든 JSON 파일 찾기
    private static func getAvailableJSONFiles() -> [String] {
        guard let resourcePath = Bundle.main.resourcePath else { return [] }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
            return files.filter { $0.hasPrefix("zoo_data_") && $0.hasSuffix(".json") }
                .sorted(by: >)  // 최신 날짜부터
        } catch {
            print("JSON 파일 검색 실패: \(error)")
            return []
        }
    }
    
    /// 가장 최신 JSON 파일 가져오기
    private static func getLatestJSONFile() -> String? {
        let files = getAvailableJSONFiles()
        return files.first
    }
    
    /// JSON 파일에서 메타데이터 가져오기
    private static func getJSONMetadata(from fileName: String) -> (lastUpdated: String, refreshBingoAnimals: Bool)? {
        guard let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        // metadata에서 last_updated 추출
        let lastUpdated: String
        if let metadata = jsonObject["metadata"] as? [String: Any],
           let lastUpdatedValue = metadata["last_updated"] as? String {
            lastUpdated = lastUpdatedValue
        } else {
            lastUpdated = ""
        }
        
        // refresh_bingo_animals 추출
        let refreshBingoAnimals = jsonObject["refresh_bingo_animals"] as? Bool ?? false
        
        return (lastUpdated: lastUpdated, refreshBingoAnimals: refreshBingoAnimals)
    }
    
    /// 파일명에서 날짜 추출 (zoo_data_YYYY_MM_DD.json 형식)
    private static func extractDateFromFileName(_ fileName: String) -> String {
        let components = fileName.replacingOccurrences(of: ".json", with: "")
            .replacingOccurrences(of: "zoo_data_", with: "")
            .replacingOccurrences(of: "_", with: "-")
        return components
    }
    
    /// BingoAnimal 테이블 초기화 (새 시즌 시작)
    private static func clearBingoAnimals(in context: ModelContext) async {
        do {
            let descriptor = FetchDescriptor<BingoAnimal>()
            let bingoAnimals = try context.fetch(descriptor)
            print("🗑️ 삭제할 BingoAnimal 개수: \(bingoAnimals.count)")
            
            for bingoAnimal in bingoAnimals {
                print("  - 삭제: BingoAnimal ID=\(bingoAnimal.id), 빙고번호=\(bingoAnimal.bingoNumber)")
                context.delete(bingoAnimal)
            }
            
            try context.save()
            print("✅ BingoAnimal 데이터 삭제 완료 (새 시즌 시작)")
            
            // 삭제 후 확인
            let checkDescriptor = FetchDescriptor<BingoAnimal>()
            let remainingAnimals = try context.fetch(checkDescriptor)
            print("🔍 삭제 후 남은 BingoAnimal 개수: \(remainingAnimals.count)")
            
        } catch {
            print("❌ BingoAnimal 데이터 삭제 실패: \(error)")
        }
    }
    


}
