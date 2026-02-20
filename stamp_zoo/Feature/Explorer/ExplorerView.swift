//
//  ExplorerView.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI
import SwiftData

struct ExplorerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ExplorerViewModel()
    @State private var selectedCategory: Category = .all
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    
    enum Category: String, CaseIterable {
        case all = "전체"
        case zoo = "동물원"
        case aquarium = "수족관"
        
        var localizedTitle: String {
            switch self {
            case .all:
                return LocalizationHelper.shared.localizedText(
                    korean: "전체",
                    english: "All",
                    japanese: "全体",
                    chinese: "全部"
                )
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 제목
                VStack(alignment: .leading, spacing: 8) {
                    Text(localizationHelper.localizedText(
                        korean: "참가하고 있는",
                        english: "Participating",
                        japanese: "参加している",
                        chinese: "参与的"
                    ))
                        .font(.title2)
                        .fontWeight(.medium)
                    Text(localizationHelper.localizedText(
                        korean: "동물원・수족관",
                        english: "Zoos・Aquariums",
                        japanese: "動物園・水族館",
                        chinese: "动物园・水族馆"
                    ))
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // 카테고리 탭
                HStack(spacing: 8) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category.localizedTitle)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedCategory == category ? 
                                    Color("zooPopGreen") : Color.clear
                                )
                                .cornerRadius(20)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // 스크롤 뷰
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ], spacing: 10) {
                        ForEach(viewModel.filteredFacilities(for: selectedCategory), id: \.facility.id) { facilityCard in
                            NavigationLink(destination: ExplorerDetailView(
                                facility: facilityCard.facility,
                                isVisited: facilityCard.isVisited
                            )) {
                                ZooCard(
                                    imageName: facilityCard.imageName,
                                    title: facilityCard.title,
                                    subtitle: facilityCard.location,
                                    isVisited: facilityCard.isVisited,
                                    isZoo: facilityCard.isZoo
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .onAppear {
                // viewModel에 modelContext 설정
                viewModel.updateModelContext(modelContext)
            }
        }
    }
}

struct ZooCard: View {
    let imageName: String
    let title: String
    let subtitle: String
    let isVisited: Bool
    let isZoo: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 이미지 영역
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 120)
                .overlay(
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 12)
                .padding(.horizontal, 12)
            
            // 정보 영역
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                
                HStack {
                    Spacer()
                    Circle()
                        .fill(isZoo ? Color.green : Color.blue)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemGray6).opacity(0.2))
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
    }
}

#Preview {
    ExplorerView()
}

