//
//  FeedReviewCardView.swift
//  project2
//
//  피드 메인 목록의 개별 방문자 리뷰 카드 및 썸네일 서브뷰 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 피드 단일 리뷰 카드 뷰 (Apple HIG 준수)
struct FeedReviewCardView: View {
    // MARK: 시스템 라이트/다크모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 피드에 표시될 식당 및 리뷰 데이터 모델
    let restaurant: Restaurant
    let review: CommunityReview
    @State private var isHelpful = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // MARK: [상단] 작성자 아바타, 닉네임, 자치구 태그, 식당 이름 및 방문 시기
            HStack {
                // 작성자 프로필 계층형 SF Symbol 아바타
                Image(systemName: review.authorAvatar)
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 6) {
                        // 작성자 닉네임 (Semantic Subheadline Bold)
                        Text(review.authorName)
                            .font(.subheadline.weight(.bold))

                        // 광주 자치구 배지 태그 (Semantic Caption2)
                        Text("광주 \(restaurant.district.rawValue)")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(colorScheme == .dark ? 0.25 : 0.12))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    // 식당명 및 방문 시기 텍스트 (Semantic Caption)
                    Text("\(restaurant.name) • \(review.visitDate)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            // MARK: [본문] 음식 사진 정사각형 썸네일(58x58) + 5점 별점 + 2줄 말줄임 본문
            HStack(alignment: .top, spacing: 10) {
                // 대표 음식 사진 또는 웜톤 플레이스홀더 썸네일
                reviewThumbnailView(review: review, category: restaurant.category)

                VStack(alignment: .leading, spacing: 4) {
                    // 1~5점 별점 표출 (RatingStarRow 재사용 컴포넌트)
                    RatingStarRow(rating: review.rating, font: .caption2, activeColor: .yellow)

                    // 솔직 리뷰 본문 (Semantic Subheadline, 최대 2줄 말줄임)
                    Text(review.content)
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .lineSpacing(4)

                    Button {
                        isHelpful.toggle()
                    } label: {
                        Label(
                            isHelpful ? "도움이 됐어요 \(review.helpfulCount + 1)" : "도움이 됐어요 \(review.helpfulCount)",
                            systemImage: isHelpful ? "hand.thumbsup.fill" : "hand.thumbsup"
                        )
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            // 카드 테두리 선
            RoundedRectangle(cornerRadius: 14)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04), lineWidth: 1)
        )
        // 은은한 그림자 효과
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.04), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - [헬퍼 서브뷰] 리뷰 음식 사진 썸네일 뷰 (58x58)
    @ViewBuilder
    private func reviewThumbnailView(review: CommunityReview, category: FoodCategory) -> some View {
        // 실제 음식 사진 에셋이 존재하는 경우
        if let photoName = review.photoName, let uiImage = UIImage(named: photoName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.06), lineWidth: 0.8)
                )
        } else {
            // 사진 에셋이 없을 때의 대체 그라데이션 및 심볼
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.68, blue: 0.32),
                        Color(red: 0.82, green: 0.44, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: category == .dessert ? "birthday.cake.fill" : "fork.knife")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.92))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .frame(width: 58, height: 58)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.06), lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.04), radius: 3, x: 0, y: 1)
        }
    }
}

// MARK: - 프리뷰
#Preview("피드 리뷰 카드 - 라이트") {
    FeedReviewCardView(
        restaurant: RestaurantViewModel().restaurants[0],
        review: RestaurantViewModel().restaurants[0].reviews[0]
    )
    .preferredColorScheme(.light)
}

#Preview("피드 리뷰 카드 - 다크") {
    FeedReviewCardView(
        restaurant: RestaurantViewModel().restaurants[0],
        review: RestaurantViewModel().restaurants[0].reviews[0]
    )
    .preferredColorScheme(.dark)
}
