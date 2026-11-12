//
//  MyRestaurantCard.swift
//  project2
//
//  나의 맛집 리스트 화면의 단일 식당 카드 뷰 컴포넌트 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 나의 맛집 단일 카드 뷰 (Apple HIG 준수)
struct MyRestaurantCard: View {
    // MARK: 시스템 라이트/다크모드 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 표시할 식당 데이터 모델
    let restaurant: Restaurant

    // MARK: 카드 탭 시 상세 화면 오픈 콜백
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: 1. 상단 행: 식당명 및 카테고리 태그 (Semantic Headline & Caption2)
            HStack {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(restaurant.category.rawValue)
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(colorScheme == .dark ? 0.25 : 0.12))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer()
            }

            // MARK: 2. 위치 및 거리 표시 행 (Semantic Caption & Callout)
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(restaurant.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                Text(restaurant.distanceText)
                    .font(.callout.weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(Color.accentColor)
            }

            // MARK: 3. 사용자가 매긴 나만의 별점 표시 (RatingStarRow 재사용 컴포넌트 적용)
            if let rating = restaurant.myRating {
                Divider().padding(.vertical, 2)

                HStack(spacing: 4) {
                    Text("내가 준 별점:")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    RatingStarRow(rating: Double(rating), font: .caption)

                    Text("\(rating)점")
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(Color.accentColor)
                        .padding(.leading, 2)
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - 프리뷰
#Preview("나의 맛집 카드 - 라이트") {
    MyRestaurantCard(
        restaurant: RestaurantViewModel().restaurants[0],
        onTap: {}
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("나의 맛집 카드 - 다크") {
    MyRestaurantCard(
        restaurant: RestaurantViewModel().restaurants[0],
        onTap: {}
    )
    .padding()
    .preferredColorScheme(.dark)
}
