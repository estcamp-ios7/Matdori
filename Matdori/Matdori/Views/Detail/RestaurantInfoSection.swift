//
//  RestaurantInfoSection.swift
//  project2
//
//  식당 상세페이지의 주소, 영업시간, 전화번호, 주차 정보 섹션 컴포넌트 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 식당 기본 안내 정보 섹션 (Apple HIG 준수)
struct RestaurantInfoSection: View {
    // MARK: 상세 정보를 표시할 대상 식당 엔티티
    let restaurant: Restaurant

    var body: some View {
        // 식당 정보 항목들을 수직으로 12포인트 간격 배치
        VStack(alignment: .leading, spacing: 12) {
            // 1. 도로명 주소 행
            infoRow(icon: "mappin.circle.fill", label: "주소", content: restaurant.address)

            // 2. 오픈 및 마감 영업시간 행
            infoRow(icon: "clock.fill", label: "영업시간", content: restaurant.openCloseTime)

            // 3. 대표 전화번호 행
            infoRow(icon: "phone.fill", label: "전화번호", content: restaurant.phoneNumber)

            // 4. 주차 안내 행
            infoRow(icon: "car.fill", label: "주차안내", content: restaurant.parkingInfo)
        }
        // 박스 내부 안쪽 여백 설정
        .padding(14)
        // 시스템 보조 배경색 적용
        .background(Color(uiColor: .secondarySystemBackground))
        // 12포인트 곡률의 둥근 모서리 적용
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - [헬퍼 함수] 세부 정보 단일 행 빌더 (Apple HIG 준수)
    private func infoRow(icon: String, label: String, content: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            // 계층형 SF Symbol 아이콘
            Image(systemName: icon)
                .font(.subheadline)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)
                .frame(width: 20)
                

            // 정보 분류 라벨 (Semantic Subheadline Medium)
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(width: 65, alignment: .leading)
                .offset(x: -7)
            // 실제 내용 텍스트 (Semantic Subheadline)
            Text(content)
                .font(.body)
                .lineHeight(.exact(points: 25))
                .tracking(-0.3)
                .foregroundStyle(.primary)

            Spacer()
        }
    }
}

// MARK: - 프리뷰
#Preview("식당 기본 정보 섹션 - 라이트") {
    RestaurantInfoSection(restaurant: RestaurantViewModel().restaurants[0])
        .padding()
        .preferredColorScheme(.light)
}

#Preview("식당 기본 정보 섹션 - 다크") {
    RestaurantInfoSection(restaurant: RestaurantViewModel().restaurants[0])
        .padding()
        .preferredColorScheme(.dark)
}
