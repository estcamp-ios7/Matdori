//
//  FeedPostDetailView.swift
//  project2
//
//  이웃 방문자 리뷰 게시글 상세 화면 (네비게이션 푸시 형태)
//  (서브뷰 FeedPhotoGalleryView 분리 적용)
//

import SwiftUI

// MARK: - 피드 게시글 상세 화면 뷰
struct FeedPostDetailView: View {
    // MARK: 화면 닫기 및 다크모드 환경 감지
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 피드에서 선택한 식당 및 리뷰 데이터 모델
    @Bindable var viewModel: RestaurantViewModel
    let restaurant: Restaurant
    let review: CommunityReview

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: 1. 작성자 프로필 헤더 영역
                authorProfileHeader

                // MARK: 2. 음식 사진 스마트 갤러리 서브뷰
                FeedPhotoGalleryView(restaurant: restaurant, review: review)

                // MARK: 3. 5점 별점 및 식당 이름 + 방문 날짜 배지
                ratingAndDateBadge

                // MARK: 4. 솔직 방문자 리뷰 본문 카드
                reviewContentCard

                // MARK: 5. 하단 식당 상세페이지 바로가기 카드
                restaurantDirectLinkCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 40)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("리뷰 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 상단 좌측 커스텀 뒤로가기 버튼
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // 이전 화면으로 복귀
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 작성자 프로필 헤더
    private var authorProfileHeader: some View {
        HStack(spacing: 12) {
            // 원형 작성자 아바타 아이콘
            Image(systemName: review.authorAvatar)
                .font(.system(size: 24))
                .foregroundStyle(Color.accentColor)
                .frame(width: 46, height: 46)
                .background(Color.accentColor.opacity(colorScheme == .dark ? 0.25 : 0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                // 작성자 닉네임 + 쉐브론 화살표
                HStack(spacing: 4) {
                    Text(review.authorName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                }

                // 방문 이력 통계 (방문 횟수, 총 리뷰 수, 평균 별점)
                HStack(spacing: 4) {
                    Text("최근 \(review.orderCount)번 방문")
                    Text("·")
                    Text("리뷰 \(review.totalReviewCount)개")
                    Text("·")
                    Text("평균별점 \(String(format: "%.1f", review.userAvgRating))")
                }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    // MARK: - [헬퍼 서브뷰] 별점 및 방문 날짜 배지
    private var ratingAndDateBadge: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 식당 이름, 카테고리, 자치구 태그 행
            HStack(spacing: 6) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.accentColor)

                Text(restaurant.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            // 1~5점 별점 렌더링 (RatingStarRow 재사용 컴포넌트) 및 방문 날짜
            HStack(spacing: 4) {
                RatingStarRow(rating: review.rating, font: .system(size: 18), activeColor: .yellow, spacing: 4)

                Text(String(format: "%.1f", review.rating))
                    .font(.system(size: 16, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .padding(.leading, 4)

                Spacer()

                Text(review.visitDate)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - [헬퍼 서브뷰] 리뷰 본문 카드
    private var reviewContentCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("방문자 솔직 후기")
                .font(.system(size: 14, weight: .bold))

            // 줄 간격 6포인트의 가독성 높은 본문 텍스트
            Text(review.content)
                .font(.system(size: 15))
                .lineSpacing(6)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - [헬퍼 서브뷰] 하단 식당 상세페이지 바로가기 카드
    private var restaurantDirectLinkCard: some View {
        NavigationLink {
            RestaurantDetailView(viewModel: viewModel, restaurant: restaurant)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(restaurant.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(restaurant.address)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text("식당 정보")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.gray)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.gray)
            }
            .padding(14)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 프리뷰
#Preview("피드 리뷰 상세 - 라이트") {
    NavigationStack {
        FeedPostDetailView(
            viewModel: RestaurantViewModel(),
            restaurant: RestaurantViewModel().restaurants[0],
            review: RestaurantViewModel().restaurants[0].reviews[0]
        )
    }
    .preferredColorScheme(.light)
}

#Preview("피드 리뷰 상세 - 다크") {
    NavigationStack {
        FeedPostDetailView(
            viewModel: RestaurantViewModel(),
            restaurant: RestaurantViewModel().restaurants[0],
            review: RestaurantViewModel().restaurants[0].reviews[0]
        )
    }
    .preferredColorScheme(.dark)
}
