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
            Text(getLongDescription(animal.name))
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
    
    
    private func getLongDescription(_ name: String) -> String {
        switch name {
        case "늑대":
            return """
            늑대는 개과(犬科)의 대표적인 육식 동물로, 현재 가정에서 키우는 개의 조상으로 여겨집니다. 학명은 Canis lupus이며, 영어로는 Wolf 또는 Gray Wolf라고 불립니다.
            
            늑대는 뛰어난 사회성을 가진 동물로, 보통 5-10마리로 구성된 무리(팩, Pack)를 이루어 생활합니다. 무리의 구성원들은 서로 협력하여 사냥을 하고, 새끼를 기르며, 영역을 방어합니다.
            
            성체 늑대의 몸길이는 100-160cm, 어깨높이는 60-90cm 정도이며, 체중은 20-80kg까지 나갑니다. 털색은 회색, 갈색, 검은색, 흰색 등 다양하며, 지역과 계절에 따라 차이가 있습니다.
            
            늑대는 뛰어난 후각과 청각을 가지고 있어 먼 거리에서도 먹이를 찾아낼 수 있습니다. 주로 큰 유제류인 사슴, 엘크, 무스 등을 사냥하지만, 작은 동물이나 물고기도 먹습니다.
            
            과거에는 북반구 전체에 광범위하게 분포했지만, 인간의 활동으로 인해 서식지가 크게 줄어들었습니다. 현재는 주로 캐나다, 알래스카, 러시아, 몽골 등에서 발견되며, 유럽과 미국 일부 지역에서도 소수가 서식하고 있습니다.
            """
        case "얼룩말":
            return """
            얼룩말은 말과(馬科)에 속하는 동물로, 온몸에 특유의 검은색과 흰색 줄무늬가 있는 것이 특징입니다. 학명은 종에 따라 다르며, 평원얼룩말(Equus quagga), 산얼룩말(Equus zebra), 그레비얼룩말(Equus grevyii) 등이 있습니다.
            
            얼룩말의 줄무늬는 개체마다 모두 다르며, 마치 인간의 지문처럼 고유한 패턴을 가지고 있습니다. 이 줄무늬는 파리나 모기 같은 해충을 쫓아내는 역할을 하며, 포식자를 혼란시키는 효과도 있습니다.
            
            성체 얼룩말의 몸길이는 200-250cm, 어깨높이는 110-150cm 정도이며, 체중은 175-385kg까지 나갑니다. 수명은 야생에서 20-25년, 사육 환경에서는 최대 40년까지 살 수 있습니다.
            
            얼룩말은 초식동물로, 주로 풀을 뜯어먹으며 하루의 대부분을 먹이활동에 보냅니다. 건기에는 물을 찾아 긴 거리를 이동하기도 합니다.
            
            얼룩말은 무리를 이루어 생활하며, 보통 한 마리의 수컷과 여러 마리의 암컷, 그리고 새끼들로 구성됩니다. 위험을 감지하면 큰 소리로 울어 무리에게 알리고, 필요시 강력한 발차기로 자신을 방어합니다.
            
            현재 얼룩말은 서식지 파괴와 사냥으로 인해 개체수가 감소하고 있으며, 특히 그레비얼룩말과 산얼룩말은 멸종 위기에 처해 있습니다.
            """
        case "하마":
            return """
            하마는 하마과(河馬科)에 속하는 대형 포유동물로, 학명은 Hippopotamus amphibius입니다. 영어로는 Hippopotamus 또는 줄여서 Hippo라고 불리며, 그리스어로 '강의 말'이라는 뜻입니다.
            
            하마는 육지 포유동물 중에서 코끼리, 코뿔소 다음으로 큰 동물로, 성체의 몸길이는 300-400cm, 높이는 150cm 정도이며, 체중은 1,500-3,000kg까지 나갑니다.
            
            하마는 반수생 동물로, 낮에는 물 속에서 지내고 밤에는 육지로 올라와 풀을 뜯어먹습니다. 물 속에서 최대 5분까지 숨을 참을 수 있으며, 물 속을 걸어다니거나 수영을 할 수 있습니다.
            
            하마의 가장 특징적인 부분은 거대한 입으로, 최대 150도까지 벌릴 수 있으며, 송곳니는 길이가 50cm까지 자랍니다. 이 큰 입과 날카로운 이빨은 위협을 표현하거나 영역을 방어할 때 사용됩니다.
            
            하마는 초식동물이지만 매우 공격적인 성격을 가지고 있어, 아프리카에서 가장 위험한 동물 중 하나로 여겨집니다. 영역 의식이 강하며, 자신의 영역에 침입하는 것을 허용하지 않습니다.
            
            하마는 주로 아프리카의 사하라 사막 이남 지역의 강이나 호수 근처에서 서식합니다. 현재는 서식지 파괴와 사냥으로 인해 개체수가 감소하고 있어 보호가 필요한 상황입니다.
            """
        case "치타":
            return """
            치타는 고양이과(猫科)에 속하는 육식 동물로, 학명은 Acinonyx jubatus입니다. 영어로는 Cheetah라고 불리며, 육상 동물 중에서 가장 빠른 속도로 달릴 수 있는 동물로 유명합니다.
            
            치타는 최고 시속 110-120km까지 달릴 수 있으며, 0에서 시속 100km까지 단 3초 만에 가속할 수 있습니다. 이러한 놀라운 속도는 유연한 척추, 긴 다리, 그리고 특별한 발톱 구조 덕분입니다.
            
            성체 치타의 몸길이는 110-150cm, 꼬리 길이는 60-80cm 정도이며, 체중은 35-75kg입니다. 몸은 날씬하고 다리가 길며, 작은 머리와 깊은 가슴을 가지고 있습니다.
            
            치타의 털은 황금색 바탕에 검은색 원형 반점이 있으며, 얼굴에는 눈에서 입까지 이어지는 검은색 줄무늬가 있습니다. 이 줄무늬는 '눈물 자국'이라고 불리며, 햇빛을 차단하여 사냥 시 시야를 개선하는 역할을 합니다.
            
            치타는 주로 낮에 사냥을 하며, 주된 먹이는 가젤, 임팔라 등의 중소형 영양입니다. 사냥 성공률은 약 50% 정도로, 다른 대형 고양이과 동물보다 높은 편입니다.
            
            현재 치타는 서식지 파괴와 인간과의 충돌로 인해 멸종 위기에 처해 있으며, 전 세계적으로 약 7,000-10,000마리 정도만 남아있는 것으로 추정됩니다.
            """
        case "북극곰":
            return """
            북극곰은 곰과(熊科)에 속하는 대형 육식 동물로, 학명은 Ursus maritimus입니다. 영어로는 Polar Bear라고 불리며, 북극 지역의 대표적인 동물입니다.
            
            북극곰은 세계에서 가장 큰 육식 동물 중 하나로, 성체 수컷의 몸길이는 250-300cm, 체중은 350-680kg까지 나갑니다. 암컷은 수컷보다 작아서 체중이 150-250kg 정도입니다.
            
            북극곰의 털은 실제로는 무색투명하지만 햇빛을 반사하여 흰색으로 보입니다. 이 털은 두겹으로 되어 있어 극한의 추위에서도 체온을 유지할 수 있게 해줍니다. 피부는 검은색으로, 햇빛을 흡수하여 체온을 높이는 역할을 합니다.
            
            북극곰은 뛰어난 수영 능력을 가지고 있어 시속 6km로 수영할 수 있으며, 최대 100km까지 헤엄칠 수 있습니다. 또한 얼음 위에서 시속 40km까지 달릴 수 있습니다.
            
            북극곰의 주된 먹이는 물개, 특히 고리무늬물개입니다. 얼음 위에서 물개가 숨을 쉬기 위해 올라오는 구멍을 기다렸다가 사냥합니다. 뛰어난 후각으로 1km 떨어진 곳의 물개도 감지할 수 있습니다.
            
            북극곰은 주로 북극해의 해빙 지역에서 서식하며, 캐나다, 알래스카, 러시아, 그린란드, 노르웨이 등의 북극 지역에 분포합니다.
            
            현재 북극곰은 기후 변화로 인한 해빙 감소로 서식지를 잃고 있어 멸종 위기에 처해 있습니다. 전 세계적으로 약 20,000-25,000마리 정도가 남아있는 것으로 추정됩니다.
            """
        case "바다사자":
            return """
            바다사자는 바다사자과(海獅科)에 속하는 해양 포유동물로, 학명은 종에 따라 다르며, 캘리포니아바다사자(Zalophus californianus)가 가장 잘 알려져 있습니다.
            
            바다사자는 물개와 비슷하지만 더 큰 몸집과 긴 목을 가지고 있습니다. 성체 수컷의 몸길이는 200-250cm, 체중은 200-400kg이며, 암컷은 150-200cm, 체중 80-110kg 정도입니다.
            
            바다사자의 가장 큰 특징은 뛰어난 수영 능력과 육상에서의 이동 능력입니다. 물 속에서는 시속 35km까지 헤엄칠 수 있으며, 최대 200m 깊이까지 잠수할 수 있습니다. 육상에서는 네 다리로 걸을 수 있어 물개보다 훨씬 민첩하게 이동합니다.
            
            바다사자는 매우 지능이 높은 동물로, 복잡한 훈련을 받을 수 있어 수족관이나 해양 공원에서 쇼를 하기도 합니다. 또한 뛰어난 사회성을 가지고 있어 무리를 이루어 생활합니다.
            
            바다사자의 주된 먹이는 물고기, 오징어, 갑각류 등입니다. 하루에 체중의 5-20%에 해당하는 먹이를 섭취하며, 사냥을 위해 하루에 여러 번 바다로 나갑니다.
            
            번식기에는 해안의 모래사장이나 바위 위에서 큰 무리를 이루며, 수컷은 자신의 영역을 확보하기 위해 치열한 경쟁을 벌입니다. 임신 기간은 약 11개월이며, 보통 한 번에 한 마리의 새끼를 낳습니다.
            
            바다사자는 태평양 연안 지역에 주로 서식하며, 캘리포니아, 멕시코, 갈라파고스 제도, 호주, 뉴질랜드 등에서 발견됩니다. 현재는 해양 오염과 어업 활동으로 인해 일부 종이 위험에 처해 있습니다.
            """
        default:
            return animal.detail.isEmpty ? LocalizationHelper.shared.localizedText(
                korean: "이 동물에 대한 자세한 정보를 수집 중입니다.",
                english: "Detailed information about this animal is being collected.",
                japanese: "この動物の詳細情報を収集中です。",
                chinese: "正在收集这个动物的详细信息。"
            ) : animal.detail
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
