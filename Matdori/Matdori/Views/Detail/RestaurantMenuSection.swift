//
//  RestaurantMenuSection.swift
//  project2
//
//  식당 상세페이지의 메뉴 및 가격 목록 섹션 컴포넌트 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 식당 메뉴 및 가격 섹션 (Apple HIG 준수)
struct RestaurantMenuSection: View {
    // MARK: 메뉴 목록을 보유한 대상 식당 데이터 모델
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 섹션 헤더 타이틀 (Semantic Headline)
            Text("메뉴 및 가격")
                .font(.headline)

            // 메뉴 행 리스트 박스
            VStack(spacing: 0) {
                // 식당의 전체 메뉴 항목 순회
                ForEach(restaurant.menus) { menu in
                    HStack {
                        // 좌측: 메뉴명 + 시그니처 대표 배지 (Semantic Subheadline)
                        HStack(spacing: 6) {
                            Text(menu.name)
                                .font(.subheadline.weight(menu.isSignature ? .bold : .regular))

                            // 대표 메뉴인 경우 주황색 '대표' 배지 표시 (Semantic Caption2)
                            if menu.isSignature {
                                Text("대표")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.orange)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }

                        Spacer()

                        // 우측: 포맷팅된 가격 문자열 (Semantic Callout & 모노스페이스 고정폭)
                        Text(menu.price)
                            .font(.callout.weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .frame(minHeight: 44) // Apple HIG 최소 행 높이 44pt 보장
                    .padding(.vertical, 2)

                    // 마지막 메뉴 항목이 아닐 경우 구분선 노출
                    if menu.id != restaurant.menus.last?.id {
                        Divider()
                    }
                }
            }
            .padding(14)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - 프리뷰
#Preview("식당 메뉴 섹션 - 라이트") {
    RestaurantMenuSection(restaurant: RestaurantViewModel().restaurants[0])
        .padding()
        .preferredColorScheme(.light)
}

#Preview("식당 메뉴 섹션 - 다크") {
    RestaurantMenuSection(restaurant: RestaurantViewModel().restaurants[0])
        .padding()
        .preferredColorScheme(.dark)
}
