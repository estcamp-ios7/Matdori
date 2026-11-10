//
//  NearbyRestaurantRow.swift
//  project2
//
//  주변 맛집 리스트 화면의 단일 행 뷰 컴포넌트 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 주변 맛집 단일 행 뷰 (Apple HIG 준수)
struct NearbyRestaurantRow: View {
    // MARK: 표시할 식당 데이터 모델
    let restaurant: Restaurant

    var body: some View {
        HStack(spacing: 12) {
            // MARK: 좌측 정보 영역 (식당명, 평점, 저장됨 태그, 카테고리, 자치구, 대표 메뉴)
            VStack(alignment: .leading, spacing: 4) {
                // 상단: 식당 이름 + 별점 + 저장됨 배지
                HStack(spacing: 6) {
                    // 식당 명칭 (Semantic Headline)
                    Text(restaurant.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    // 기본 평점 표시 (예: ★ 4.8)
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)

                        Text(String(format: "%.1f", restaurant.baseRating))
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                    }

                    // 북마크된 식당인 경우 주황색 '저장됨' 배지 표시
                    if restaurant.isSaved {
                        Text("저장됨")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }

                // 하단 보조 정보: 카테고리 • 자치구 • 대표 시그니처 메뉴명 (Semantic Caption)
                HStack(spacing: 4) {
                    // 음식 카테고리
                    Text(restaurant.category.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.orange)

                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    // 광주 상권/자치구
                    Text(restaurant.district.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // 대표 메뉴가 존재할 경우 점과 함께 메뉴명 표출
                    if let signatureMenu = restaurant.menus.first(where: { $0.isSignature }) ?? restaurant.menus.first {
                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text(signatureMenu.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            // MARK: 우측: 사용자 위치 기준 거리 표시 (Semantic Callout & 고정폭 폰트)
            Text(restaurant.distanceText)
                .font(.callout.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 48) // Apple HIG 리스트 행 최소 높이 48pt 보장
        .padding(.vertical, 4)
    }
}

// MARK: - 프리뷰
#Preview("주변 맛집 단일 행 - 라이트") {
    NearbyRestaurantRow(restaurant: RestaurantViewModel().restaurants[0])
        .padding()
        .preferredColorScheme(.light)
}

#Preview("주변 맛집 단일 행 - 다크") {
    NearbyRestaurantRow(restaurant: RestaurantViewModel().restaurants[0])
        .padding()
        .preferredColorScheme(.dark)
}
