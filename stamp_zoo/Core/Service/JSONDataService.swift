//
//  JSONDataService.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import Foundation
import SwiftData

/// JSON 파일을 통한 동적 데이터 관리 서비스
@MainActor
class JSONDataService {
    /// 앱 최초 출시 시즌 (마이그레이션 기본값 및 JSON 로드 전 폴백용)
    static let initialSeason = "2025"

    static let shared = JSONDataService()

    private let userDefaults = UserDefaults.standard
    private let lastUpdateKey = "zoo_data_last_update_date"
    private let lastRefreshedSeasonKey = "zoo_data_last_refreshed_season"

    /// 현재 로드된 시즌 (QR 수집 시 사용)
    private(set) var currentSeason: String = initialSeason
    
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
            #if DEBUG
            print("데이터 확인 중 오류: \(error)")
            #endif
            return false
        }
    }
    
    /// 새로운 업데이트가 있는지 확인하고 데이터 업데이트
    private static func checkAndUpdateData(in context: ModelContext) async {
        #if DEBUG
        print("🔍 업데이트 확인 중...")
        #endif
        guard let latestDataFile = getLatestJSONFile() else {
            #if DEBUG
            print("사용 가능한 JSON 파일이 없습니다.")
            #endif
            return
        }

        guard let jsonMetadata = getJSONMetadata(from: latestDataFile) else {
            #if DEBUG
            print("JSON 메타데이터를 읽을 수 없습니다.")
            #endif
            return
        }

        let jsonLastUpdated = jsonMetadata.lastUpdated
        let jsonSeason = jsonMetadata.season
        let storedLastUpdate = shared.userDefaults.string(forKey: shared.lastUpdateKey) ?? ""
        let storedSeason = shared.userDefaults.string(forKey: shared.lastRefreshedSeasonKey) ?? ""

        // 현재 시즌 업데이트
        shared.currentSeason = jsonSeason

        #if DEBUG
        print("📅 JSON last_updated: \(jsonLastUpdated)")
        print("📅 저장된 마지막 업데이트: \(storedLastUpdate)")
        print("🏷️ JSON season: \(jsonSeason)")
        print("🏷️ 저장된 season: \(storedSeason)")
        #endif

        // 데이터 업데이트 조건: JSON의 last_updated가 더 최신인 경우
        let needsDataUpdate = jsonLastUpdated > storedLastUpdate

        // 빙고 리셋 조건: 시즌이 변경된 경우 (한 번만 실행됨)
        let needsSeasonReset = jsonSeason != storedSeason && !storedSeason.isEmpty

        if needsDataUpdate {
            #if DEBUG
            print("🆕 새로운 데이터 업데이트 발견: \(jsonLastUpdated)")
            #endif
            await loadJSONData(from: latestDataFile, in: context)
            shared.userDefaults.set(jsonLastUpdated, forKey: shared.lastUpdateKey)
        } else if needsSeasonReset {
            // 데이터는 최신이지만 시즌이 바뀐 경우 (빙고만 리셋)
            #if DEBUG
            print("🔄 시즌 변경 감지: \(storedSeason) → \(jsonSeason), 빙고 리셋")
            #endif
            await clearBingoAnimals(in: context)
        } else {
            #if DEBUG
            print("✅ 데이터가 최신 상태입니다.")
            #endif
        }

        // 시즌 정보 저장 (리셋 여부와 관계없이 항상 최신화)
        shared.userDefaults.set(jsonSeason, forKey: shared.lastRefreshedSeasonKey)
    }
    
    /// 최신 JSON 파일 로드 (첫 실행)
    private static func loadLatestJSONData(in context: ModelContext) async {
        guard let latestDataFile = getLatestJSONFile() else {
            #if DEBUG
            print("JSON 파일을 찾을 수 없습니다. 앱 번들에 JSON 파일을 추가해주세요.")
            #endif
            return
        }

        await loadJSONData(from: latestDataFile, in: context)

        let fileDate = extractDateFromFileName(latestDataFile)
        shared.userDefaults.set(fileDate, forKey: shared.lastUpdateKey)

        // 첫 실행 시 시즌 정보도 저장
        if let jsonMetadata = getJSONMetadata(from: latestDataFile) {
            shared.currentSeason = jsonMetadata.season
            shared.userDefaults.set(jsonMetadata.season, forKey: shared.lastRefreshedSeasonKey)
        }
    }
    
    /// 특정 JSON 파일에서 데이터 로드
    private static func loadJSONData(from fileName: String, in context: ModelContext) async {
        guard let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            #if DEBUG
            print("JSON 파일을 찾을 수 없습니다: \(fileName)")
            #endif
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let zooData = try JSONDecoder().decode(ZooDataFile.self, from: data)
            
            // 기존 데이터 삭제
            await clearExistingData(in: context)
            
            // 새로운 데이터 저장
            await saveJSONDataToSwiftData(zooData, in: context)
            
            #if DEBUG
            print("데이터 로드 완료: \(zooData.metadata.description)")
            print("시설 \(zooData.facilities.count)개, 동물 \(zooData.animals.count)개 로드됨")
            #endif
            
        } catch {
            #if DEBUG
            print("JSON 데이터 로드 실패: \(error)")
            #endif
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
            #if DEBUG
            print("기존 동물원 데이터 삭제 완료 (스탬프 수집 데이터는 보존)")
            #endif
        } catch {
            #if DEBUG
            print("기존 데이터 삭제 실패: \(error)")
            #endif
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
                    #if DEBUG
                    print("시설을 찾을 수 없습니다: \(animalJSON.facilityId)")
                    #endif
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
            
            // 시즌 비교를 통한 빙고 리셋 (BingoAnimal만 초기화)
            let jsonSeason = zooData.metadata.season
            let storedSeason = shared.userDefaults.string(forKey: shared.lastRefreshedSeasonKey) ?? ""

            // 현재 시즌 업데이트
            shared.currentSeason = jsonSeason

            #if DEBUG
            print("🏷️ JSON season: \(jsonSeason), 저장된 season: \(storedSeason)")
            #endif

            if jsonSeason != storedSeason && !storedSeason.isEmpty {
                #if DEBUG
                print("🚀 새 시즌 시작: \(storedSeason) → \(jsonSeason) - 빙고 게임 초기화")
                #endif
                await clearBingoAnimals(in: context)
                #if DEBUG
                print("✅ 빙고 게임(BingoAnimal) 초기화 완료")
                print("📝 StampCollection은 보존됨 (Field Guide 수집 기록 유지)")
                #endif
            } else {
                #if DEBUG
                print("⏸️ 시즌 변경 없음 - 기존 빙고 데이터 유지")
                #endif
            }

            // 시즌 정보 저장
            shared.userDefaults.set(jsonSeason, forKey: shared.lastRefreshedSeasonKey)

            try context.save()
            #if DEBUG
            print("JSON 데이터 저장 완료")
            #endif
        } catch {
            #if DEBUG
            print("JSON 데이터 저장 실패: \(error)")
            #endif
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
            #if DEBUG
            print("JSON 파일 검색 실패: \(error)")
            #endif
            return []
        }
    }
    
    /// 가장 최신 JSON 파일 가져오기
    private static func getLatestJSONFile() -> String? {
        let files = getAvailableJSONFiles()
        return files.first
    }
    
    /// JSON 파일에서 메타데이터 가져오기
    private static func getJSONMetadata(from fileName: String) -> (lastUpdated: String, season: String)? {
        guard let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        // metadata에서 last_updated, season 추출
        let lastUpdated: String
        let season: String
        if let metadata = jsonObject["metadata"] as? [String: Any] {
            lastUpdated = metadata["last_updated"] as? String ?? ""
            season = metadata["season"] as? String ?? initialSeason
        } else {
            lastUpdated = ""
            season = initialSeason
        }

        return (lastUpdated: lastUpdated, season: season)
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
            #if DEBUG
            print("🗑️ 삭제할 BingoAnimal 개수: \(bingoAnimals.count)")
            #endif

            for bingoAnimal in bingoAnimals {
                #if DEBUG
                print("  - 삭제: BingoAnimal ID=\(bingoAnimal.id), 빙고번호=\(bingoAnimal.bingoNumber)")
                #endif
                context.delete(bingoAnimal)
            }

            try context.save()
            #if DEBUG
            print("✅ BingoAnimal 데이터 삭제 완료 (새 시즌 시작)")
            #endif

            // 삭제 후 확인
            let checkDescriptor = FetchDescriptor<BingoAnimal>()
            let remainingAnimals = try context.fetch(checkDescriptor)
            #if DEBUG
            print("🔍 삭제 후 남은 BingoAnimal 개수: \(remainingAnimals.count)")
            #endif

        } catch {
            #if DEBUG
            print("❌ BingoAnimal 데이터 삭제 실패: \(error)")
            #endif
        }
    }
    


}
