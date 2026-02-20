//
//  stamp_zooApp.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI
import SwiftData

@main
struct stamp_zooApp: App {
    @StateObject private var localizationManager = LocalizationManager.shared
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Animal.self,
            Facility.self,
            StampCollection.self,
            BingoCard.self,
            BingoAnimal.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // JSON 데이터 로드 체크
            Task {
                await JSONDataService.loadDataIfNeeded(in: container)
            }
            
            return container
        } catch {
            // ModelContainer 생성 실패 시 인메모리로 폴백
            print("Could not create ModelContainer: \(error). Falling back to in-memory store.")
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("Could not create fallback ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
    

}
