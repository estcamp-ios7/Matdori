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

    // MARK: 별점 즉각 변경 시 호출되는 콜백
    var onRatingChange: (Int) -> Void

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
                    .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.12))
                    .foregroundStyle(Color.orange)
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
                    .foregroundStyle(Color.orange)
            }

            // MARK: 3. 사용자가 매긴 나만의 별점 표시 (HIG 44pt 터치 타깃 보장)
            if let rating = restaurant.myRating {
                Divider().padding(.vertical, 2)

                HStack {
                    Text("내가 준 별점:")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    // 1~5점 별점 인터랙티브 버튼 그룹 (최소 터치 높이 44pt)
                    HStack(spacing: 0) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                onRatingChange(star)
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.subheadline)
                                    .foregroundStyle(star <= rating ? Color.orange : Color.gray.opacity(0.4))
                                    .frame(width: 38, height: 44) // HIG 터치 높이 44pt 보장
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
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
        onTap: {},
        onRatingChange: { _ in }
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("나의 맛집 카드 - 다크") {
    MyRestaurantCard(
        restaurant: RestaurantViewModel().restaurants[0],
        onTap: {},
        onRatingChange: { _ in }
    )
    .padding()
    .preferredColorScheme(.dark)
}
