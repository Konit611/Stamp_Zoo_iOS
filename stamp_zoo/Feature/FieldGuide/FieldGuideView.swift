//
//  FieldGuideView.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI
import SwiftData

struct FieldGuideView: View {
    @Query private var animals: [Animal]
    @Query private var stampCollections: [StampCollection]
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    @Environment(\.modelContext) private var modelContext

    // 수집된 동물들 (StampCollection 기반 - 영구 수집 기록)
    private var collectedAnimals: [Animal] {
        let collectedAnimalIds = Set(stampCollections.map { $0.animalId })

        return animals.filter { animal in
            collectedAnimalIds.contains(animal.id.uuidString)
        }
    }
    
    // 도감 슬롯 계산 (수집된 동물 + 여유분, 3의 배수로 맞춤)
    private var totalFieldGuideSlots: Range<Int> {
        let collectedCount = collectedAnimals.count
        let minSlots = 12
        let slotsNeeded = max(collectedCount + 6, minSlots) // 수집된 동물 + 여유분 또는 최소 개수
        let roundedSlots = ((slotsNeeded + 2) / 3) * 3 // 3의 배수로 맞춤
        return 0..<roundedSlots
    }
    

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 제목
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationHelper.localizedText(
                            korean: "수집한",
                            english: "Collected",
                            japanese: "収集した",
                            chinese: "收集的"
                        ))
                            .font(.title)
                            .fontWeight(.bold)
                        Text(localizationHelper.localizedText(
                            korean: "동물도감을 보기",
                            english: "Animal Guide",
                            japanese: "動物図鑑を見る",
                            chinese: "动物图鉴"
                        ))
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // 도감 격자
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                        ForEach(totalFieldGuideSlots, id: \.self) { index in
                            animalCell(for: index)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGray6))
        }
    }
    
    // MARK: - Animal Cell
    private func animalCell(for index: Int) -> some View {
        let animal = getAnimal(at: index)
        
        return Group {
            if let animal = animal {
                // 수집된 동물 - 클릭 가능
                NavigationLink(destination: FieldGuideDetailView(animal: animal)) {
                    Group {
                        if let image = UIImage(named: animal.stampImage) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 100)
                                .clipped()
                                .overlay(
                                    // 미수집된 동물은 어두운 오버레이 추가
                                    Group {
                                        if !isAnimalCollected(animal) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.black.opacity(0.7))
                                                .overlay(
                                                    Image(systemName: "questionmark")
                                                        .font(.title2)
                                                        .foregroundColor(.white)
                                                )
                                        }
                                    }
                                )
                        } else {
                            // 이미지 로드 실패 시 기본 이미지
                            Image("default_image")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 100)
                                .clipped()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // 빈 도감 슬롯 - 클릭 불가
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("zooBackgroundBlack"))
                    .frame(height: 100)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getAnimal(at index: Int) -> Animal? {
        // 수집된 동물들만 표시
        if index < collectedAnimals.count {
            return collectedAnimals[index]
        }
        return nil
    }
    
    private func isAnimalCollected(_ animal: Animal) -> Bool {
        stampCollections.contains { $0.animalId == animal.id.uuidString }
    }
}

#Preview {
    FieldGuideView()
        .modelContainer(for: [Animal.self, Facility.self])
}

