//
//  FieldGuideDetailView.swift
//  stamp_zoo
//
//  Created by GEUNIL on 2025/07/05.
//

import SwiftUI
import SwiftData

struct FieldGuideDetailView: View {
    let animal: Animal
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                animalImageView
                animalInfoView
            }
            .background(Color("zooPopGreen").opacity(0.3))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100) // 탭바 공간 확보
        }
        .background(Color(.systemGray6))
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 1) // 상단 SafeArea 확실히 보호
        }
        .navigationTitle(animal.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
    }
    
    private var animalImageView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.7))
                .frame(height: 400)
                .overlay(
                    Group {
                        if let image = UIImage(named: animal.image) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 400)
                                .clipped()
                        } else {
                            Image("default_image")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 400)
                                .clipped()
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20) // 네비게이션 바와의 겹침 방지를 위한 추가 패딩
    }
    
    private var animalInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 동물 이름과 동물원 로고
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(animal.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // 동물원 로고
                if let logoImage = UIImage(named: animal.facility.logoImage) {
                    Image(uiImage: logoImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                } else {
                    // 로고 이미지가 없을 때 기본 아이콘
                    Image(systemName: "building.2")
                        .font(.system(size: 40))
                        .foregroundColor(.black.opacity(0.6))
                        .frame(width: 60, height: 60)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 상세 설명
            Text(animal.detail)
                .font(.system(size: 14))
                .lineSpacing(6)
                .foregroundColor(.black.opacity(0.9))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    
    private var backButton: some View {
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

//#Preview {
//    // 샘플 동물 데이터로 프리뷰
//    let sampleFacility = Facility(
//        name: "샘플 동물원",
//        image: "zoo_main",
//        logoImage: "zoo_logo", 
//        mapImage: "zoo_map",
//        mapLink: "https://example.com",
//        detail: "샘플 동물원입니다."
//    )
//    
//    let sampleAnimal = Animal(
//        name: "늑대",
//        detail: "늑대는 개과에 속하는 육식 포유동물로, 현재 개의 조상으로 여겨집니다. 뛰어난 사회성을 가진 동물로, 무리(팩)를 이루어 생활합니다.",
//        image: "wolf_image",
//        stampImage: "wolf_stamp",
//        facility: sampleFacility
//    )
//    
//    NavigationView {
//        FieldGuideDetailView(animal: sampleAnimal)
//    }
//} 
