//
//  FeedPostDetailView.swift
//  project2
//
//  이웃 방문자 리뷰 게시글 상세 화면 (네비게이션 푸시 형태)
//  - 작성자 프로필 헤더 및 5점 별점이 피드 카드와 1:1 완벽 동기화
//  - 업로드 이미지 레퍼런스에 맞춘 원형 아바타, 방문 통계, 전문 본문, 음식 사진 갤러리 지원
//  - 신고하기 버튼 제외 및 다크모드 대응
//

import SwiftUI

// MARK: - 피드 게시글 상세 화면 뷰
struct FeedPostDetailView: View {
    // MARK: [환경 변수] 화면 닫기 및 다크모드 감지
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: [전달받은 모델] 피드에서 선택한 식당 및 리뷰 데이터
    let restaurant: Restaurant
    let review: CommunityReview

    // MARK: [콜백] 하단 식당 바로가기 터치 시 식당 탐색 상세화면 열기
    var onSelectRestaurant: ((Restaurant) -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: 1. 작성자 프로필 헤더 영역 (피드와 100% 동기화)
                HStack(spacing: 12) {
                    // 원형 아바타 (피드의 review.authorAvatar와 동기화)
                    Image(systemName: review.authorAvatar)
                        .font(.system(size: 24))
                        .foregroundStyle(Color.orange)
                        .frame(width: 46, height: 46)
                        .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        // 작성자 닉네임 + chevron.right (예: 배고파 >)
                        HStack(spacing: 4) {
                            Text(review.authorName)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.gray.opacity(0.6))
                        }

                        // 활동 이력 통계 (방문 횟수, 리뷰 수, 평균 별점)
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
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // MARK: 2. 별점 및 방문 메타정보 영역 (피드의 review.rating과 완전 동기화)
                HStack(spacing: 8) {
                    // 노란색 5점 별점 (피드와 일치)
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= Int(review.rating) ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.yellow)
                        }
                    }

                    Text("\(review.visitDate) 방문")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)

                    Text("•")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)

                    Text("찐방문 인증")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.orange)
                }
                .padding(.horizontal, 16)

                // MARK: 3. 리뷰 원문 전문 본문 (말줄임 없이 전문 노출)
                Text(review.content)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .lineSpacing(6)
                    .padding(.horizontal, 16)

                // MARK: 4. 음식 사진 갤러리 영역 (레퍼런스 이미지의 나란히 배치된 음식 사진)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        // 1번 음식 사진 (케이크/디저트/메인 요리 썸네일)
                        foodGalleryPhoto(index: 1, title: "대표 메뉴 컷")

                        // 2번 음식 사진 (클로즈업 컷)
                        foodGalleryPhoto(index: 2, title: "상세 컷")
                    }
                    .padding(.horizontal, 16)
                }

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // MARK: 5. 하단 리뷰 대상 식당 안내 카드
                VStack(alignment: .leading, spacing: 10) {
                    Text("리뷰 대상 맛집")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(restaurant.name)
                                    .font(.system(size: 15, weight: .bold))

                                Text(restaurant.category.rawValue)
                                    .font(.system(size: 11, weight: .semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.12))
                                    .foregroundStyle(Color.orange)
                                    .clipShape(Capsule())
                            }

                            Text("📍 \(restaurant.address)")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        // 식당 상세 탐색으로 연결되는 버튼
                        if let onSelectRestaurant {
                            Button {
                                onSelectRestaurant(restaurant)
                            } label: {
                                HStack(spacing: 4) {
                                    Text("식당 보기")
                                        .font(.system(size: 12, weight: .semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.12))
                                .foregroundStyle(Color.orange)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("리뷰 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        // 네비게이션 툴바 뒤로가기 버튼 구성 (신고하기 버튼 제외)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    // MARK: - [헬퍼 함수] 음식 갤러리 사진 뷰 빌더
    @ViewBuilder
    private func foodGalleryPhoto(index: Int, title: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            // 따뜻한 톤의 웜톤 그라데이션 및 부드러운 코너 라운딩
            LinearGradient(
                colors: index == 1
                    ? [Color(red: 0.95, green: 0.68, blue: 0.32), Color(red: 0.82, green: 0.44, blue: 0.18)]
                    : [Color(red: 0.93, green: 0.60, blue: 0.28), Color(red: 0.78, green: 0.38, blue: 0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 음식 사진 느낌을 주는 카테고리 심볼 아이콘
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: restaurant.category == .dessert ? "birthday.cake.fill" : "fork.knife")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                    Spacer()
                }
                Spacer()
            }

            // 하단 사진 캡션 배지
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.35))
                .clipShape(Capsule())
                .padding(8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 프리뷰
#Preview("피드 게시글 상세 - 라이트") {
    NavigationStack {
        FeedPostDetailView(
            restaurant: RestaurantViewModel().restaurants[0],
            review: RestaurantViewModel().restaurants[0].reviews[0]
        )
    }
    .preferredColorScheme(.light)
}

#Preview("피드 게시글 상세 - 다크") {
    NavigationStack {
        FeedPostDetailView(
            restaurant: RestaurantViewModel().restaurants[0],
            review: RestaurantViewModel().restaurants[0].reviews[0]
        )
    }
    .preferredColorScheme(.dark)
}
