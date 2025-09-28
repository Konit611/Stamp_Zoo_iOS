//
//  BingoDetailView.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI
import SwiftData

struct BingoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationHelper = LocalizationHelper.shared
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BingoHomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 빙고 보드 섹션
                VStack(spacing: 20) {
                    // 3x3 그리드 빙고 보드 (BingoHomeView와 동일)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                        ForEach(0..<9, id: \.self) { index in
                            stampCell(for: index)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                }
                .padding(.bottom, 20)
                
                // 스탬프 랠리 정보 섹션
                VStack(alignment: .leading, spacing: 16) {
                    // 제목
                    Text(localizationHelper.localizedText(
                        korean: "와쿠와쿠\n스탬프 랠리",
                        english: "Exciting\nStamp Rally",
                        japanese: "ワクワク\nスタンプラリー",
                        chinese: "激动人心的\n邮票拉力赛"
                    ))
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                    
                    // 설명 텍스트
                    Text(localizationHelper.localizedText(
                        korean: "동물원과 수족관을 탐험하며 다양한 동물들을 만나보세요! QR 코드를 스캔하여 스탬프를 수집하고, 빙고를 완성해보세요.\n\n각 동물들의 특별한 이야기와 함께 재미있는 학습 경험을 제공합니다. 모든 스탬프를 모아서 특별한 보상을 받아보세요!\n\n가족과 함께 즐기는 교육적이고 재미있는 체험이 여러분을 기다리고 있습니다.",
                        english: "Explore zoos and aquariums to meet various animals! Scan QR codes to collect stamps and complete bingo.\n\nEnjoy fun learning experiences with special stories about each animal. Collect all stamps to receive special rewards!\n\nEducational and fun experiences for the whole family await you.",
                        japanese: "動物園と水族館を探検して、様々な動物に出会いましょう！QRコードをスキャンしてスタンプを集め、ビンゴを完成させましょう。\n\n各動物の特別な物語と一緒に楽しい学習体験を提供します。すべてのスタンプを集めて特別な報酬を受け取りましょう！\n\n家族みんなで楽しむ教育的で楽しい体験があなたを待っています。",
                        chinese: "探索动物园和水族馆，遇见各种动物！扫描二维码收集邮票，完成宾果游戏。\n\n通过每种动物的特殊故事享受有趣的学习体验。收集所有邮票获得特殊奖励！\n\n适合全家享受的教育性和趣味性体验等待着您。"
                    ))
                        .font(.system(size: 16))
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle(localizationHelper.localizedText(
            korean: "빙고 상세",
            english: "Bingo Details",
            japanese: "ビンゴ詳細",
            chinese: "宾果详情"
        ))
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
        }
        .onAppear {
            // viewModel에 modelContext 설정
            viewModel.updateModelContext(modelContext)
        }
    }
    
    // MARK: - Stamp Cell
    private func stampCell(for index: Int) -> some View {
        let stamp = viewModel.getStamp(at: index)
        
        return Group {
            if let stamp = stamp, stamp.isCollected, let animal = stamp.animal {
                // 수집된 스탬프 이미지로 fill
                if let image = UIImage(named: animal.stampImage) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                } else {
                    // 이미지 로드 실패 시 기본 이미지
                    Image("default_image")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                }
            } else {
                // 빈 스탬프 슬롯은 배경색으로 fill
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("zooBackgroundBlack"))
                    .frame(height: 100)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    NavigationView {
        BingoDetailView()
    }
} 

