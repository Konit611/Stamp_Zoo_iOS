//
//  ExplorerDetailView.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI

struct ExplorerDetailView: View {
    let facility: Facility
    let isVisited: Bool
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 헤더 이미지
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.opacity(0.6))
                        .frame(height: 300)
                        .overlay(
                            Group {
                                if let image = UIImage(named: facility.image) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 300)
                                        .clipped()
                                } else {
                                    // 이미지 로드 실패 시 기본 이미지
                                    Image("default_image")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 300)
                                        .clipped()
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // 정보 영역
                VStack(alignment: .leading, spacing: 16) {
                    // 제목과 로고
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(facility.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(facility.location ?? "위치 정보 없음")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 로고 이미지
                        Group {
                            if let logoImage = UIImage(named: facility.logoImage) {
                                Image(uiImage: logoImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            } else {
                                Image(systemName: "building.2")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // 설명
                    Text(facility.detail)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.black)
                        .clipShape(Circle())
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ExplorerDetailAnimalsView(
                    facility: facility
                )) {
                    HStack(spacing: 6) {
                        Text(localizationHelper.localizedText(
                            korean: "동물을 보러",
                            english: "See Animals",
                            japanese: "動物を見に",
                            chinese: "查看动物"
                        ))
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(20)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ExplorerDetailView(
            facility: Facility(
                nameKo: "쿠시로시립동물원",
                nameEn: "Kushiro City Zoo",
                nameJa: "釧路市立動物園",
                nameZh: "钏路市立动物园",
                type: .zoo,
                locationKo: "홋카이도, 쿠시로시",
                locationEn: "Hokkaido, Kushiro City",
                locationJa: "北海道、釧路市",
                locationZh: "北海道，钏路市",
                image: "deer_image",
                logoImage: "zoo_logo",
                mapImage: "zoo_map",
                mapLink: "https://example.com",
                detailKo: "다양한 동물들과 함께하는 즐거운 동물원입니다.",
                detailEn: "A zoo with various animals.",
                detailJa: "様々な動物と一緒に楽しい動物園です。",
                detailZh: "与各种动物一起的快乐动物园。",
                latitude: 42.9849,
                longitude: 144.3822,
                validationRadius: 500.0,
                facilityId: "kushiro_preview"
            ),
            isVisited: false
        )
    }
} 
