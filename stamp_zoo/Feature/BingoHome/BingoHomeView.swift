//
//  BingoHomeView.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI
import SwiftData

struct BingoHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BingoHomeViewModel()
    @State private var presentedDestination: NavigationDestination?
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    
    enum NavigationDestination {
        case settings
        case bingoDetail
        case bingoQR
        case appInfo
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 상단 헤더
                headerView()
                
                // 메인 컨텐츠
                VStack(spacing: 20) {
                    // 제목
                    titleView()
                    
                    // 스탬프 그리드
                    stampGridView()
                    
                    // QR 버튼
                    qrButton()
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGray6))
            .ignoresSafeArea(.all, edges: .top)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .settings:
                    SettingsView()
                        .navigationBarTitleDisplayMode(.inline)
                case .bingoDetail:
                    BingoDetailView()
                        .navigationBarTitleDisplayMode(.inline)
                case .bingoQR:
                    BingoQRView()
                        .navigationBarTitleDisplayMode(.inline)
                case .appInfo:
                    AppInfoView()
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .onAppear {
                // viewModel에 modelContext 설정
                viewModel.updateModelContext(modelContext)
            }
        }
    }
    
    // MARK: - Header View
    private func headerView() -> some View {
        HStack {
            // 앱 로고가 있는 하얀색 원 (탭 가능)
            NavigationLink(value: NavigationDestination.appInfo) {
                Image("app_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 45, height: 45)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 55, height: 55)
                    )
            }
            
            Spacer()
            
            // 설정 아이콘
            NavigationLink(value: NavigationDestination.settings) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    // MARK: - Title View
    private func titleView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(localizationHelper.localizedText(
                    korean: "와쿠와쿠\n스탬프 랠리",
                    english: "Exciting\nStamp Rally",
                    japanese: "ワクワク\nスタンプラリー",
                    chinese: "激动人心的\n邮票拉力赛"
                ))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // 화살표 아이콘
            NavigationLink(value: NavigationDestination.bingoDetail) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - Stamp Grid View
    private func stampGridView() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
            ForEach(0..<9, id: \.self) { index in
                stampCell(for: index)
            }
        }
        .padding(.horizontal, 10)
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
    
    // MARK: - QR Button
    private func qrButton() -> some View {
        NavigationLink(value: NavigationDestination.bingoQR) {
            Text(localizationHelper.localizedText(
                korean: "QR로 스탬프 취득",
                english: "Get Stamp with QR",
                japanese: "QRでスタンプを取得",
                chinese: "用QR获取邮票"
            ))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.green.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    BingoHomeView()
}


