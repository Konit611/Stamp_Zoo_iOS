//
//  AppInfoView.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI

struct AppInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationHelper = LocalizationHelper.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 앱 로고 섹션 (빙고 보드와 같은 위치)
                VStack(spacing: 20) {
                    // 앱 로고 - 빙고 보드 대신 큰 로고 표시
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .frame(height: 300)
                            .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        Image("app_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                }
                .padding(.bottom, 20)
                
                // 앱 정보 섹션
                VStack(alignment: .leading, spacing: 16) {
                    // 앱 제목
                    Text(localizationHelper.localizedText(
                        korean: "홋카이도 생물 보전 프로젝트",
                        english: "Hokkaido Wildlife Conservation Project",
                        japanese: "北海道産いきもの保全プロジェクト",
                        chinese: "北海道生物保护项目"
                    ))
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                    
                    // 앱 설명 텍스트
                    Text(localizationHelper.localizedText(
                        korean: "홋카이도 생물 보전 프로젝트는 홋카이도 내 동물원·수족관 9개 시설이 연계하여 홋카이도에 서식하는 야생생물의 보전을 목표로 적극적으로 조사와 연구, 보급 계몽 등을 실시하는 프로젝트입니다.\n\n협력 시설:\n• 삿포로시 마루야마 동물원\n• 아사히카와시 아사히야마 동물원\n• 오비히로 동물원\n• 구시로시 동물원\n• 오타루 수족관\n• 신삿포로 선피아자 수족관\n• 노보리베츠 마린파크 닉스\n• 연어의 고향 치토세 수족관\n• AOAO SAPPORO\n\n주요 활동:\n• 북해도 야생생물의 역내·역외 보전 활동\n• 북해도 야생생물 보전 관련 조사·연구\n• 교육 보급 계몽 활동\n• 직원 연수\n• 시설의 상호 이용",
                        english: "The Hokkaido Wildlife Conservation Project is a collaborative initiative among 9 zoos and aquariums in Hokkaido, actively conducting research, studies, and educational outreach to conserve wildlife native to Hokkaido.\n\nParticipating Facilities:\n• Sapporo Maruyama Zoo\n• Asahikawa Asahiyama Zoo\n• Obihiro Zoo\n• Kushiro City Zoo\n• Otaru Aquarium\n• New Chitose Sunpiazza Aquarium\n• Noboribetsu Marine Park Nixe\n• Chitose Salmon Aquarium\n• AOAO SAPPORO\n\nMain Activities:\n• In-situ and ex-situ conservation of Hokkaido wildlife\n• Research and studies on Hokkaido wildlife conservation\n• Educational and awareness activities\n• Staff training programs\n• Mutual utilization of facilities",
                        japanese: "北海道産いきもの保全プロジェクトとは、北海道内の動物園・水族館９園館が連携し、北海道に生息している野生生物の保全を目指し積極的に調査や研究、普及啓発等を実施していくプロジェクトです。\n\n協同園館:\n• 札幌市円山動物園\n• 旭川市旭山動物園\n• おびひろ動物園\n• 釧路市動物園\n• 小樽水族館\n• 新さっぽろサンピアザ水族館\n• 登別マリンパークニクス\n• サケのふるさと千歳水族館\n• AOAO SAPPORO\n\n具体的な活動内容:\n• 北海道の野生生物の域内・域外保全にかかる活動\n• 北海道の野生生物の保全に関する調査・研究\n• 教育普及啓発活動\n• 職員研修\n• 施設の相互利活用",
                        chinese: "北海道生物保护项目是北海道内9个动物园和水族馆联合开展的项目，旨在积极开展调查研究和宣传教育等活动，保护北海道栖息的野生生物。\n\n合作机构:\n• 札幌市圆山动物园\n• 旭川市旭山动物园\n• 带广动物园\n• 钏路市动物园\n• 小樽水族馆\n• 新札幌太阳广场水族馆\n• 登别海洋公园尼克斯\n• 鲑鱼故乡千岁水族馆\n• AOAO SAPPORO\n\n主要活动内容:\n• 北海道野生生物的就地和迁地保护活动\n• 北海道野生生物保护相关调查研究\n• 教育宣传活动\n• 员工培训\n• 设施互相利用"
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
            korean: "앱 정보",
            english: "App Info",
            japanese: "アプリ情報",
            chinese: "应用信息"
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
    }
}

#Preview {
    NavigationView {
        AppInfoView()
    }
}
