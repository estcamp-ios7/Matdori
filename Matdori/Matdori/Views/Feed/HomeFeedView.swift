//
//  HomeFeedView.swift
//  project2
//
//  숨은 맛집 발견 피드 화면 (다크모드 대응, 당겨서 새로고침 지원)
//

import SwiftUI

// MARK: - 홈 피드 화면
struct HomeFeedView: View {
    // MARK: 다크모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 뷰모델 바인딩
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 식당 선택 핸들러
    var onSelectRestaurant: (Restaurant) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: 상단 헤더 타이틀
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("숨은 맛집 발견 & 공유")
                            .font(.system(size: 22, weight: .bold))
                        Text("실제 방문자의 솔직한 찐 리뷰 탐색")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 56)

                // MARK: 이웃들이 공유한 솔직 방문자 리뷰 피드
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("🔥 이웃들이 다녀온 솔직 리뷰 피드")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    // 피드 아이템 렌더링
                    ForEach(viewModel.restaurants) { r in
                        if let firstReview = r.reviews.first {
                            VStack(alignment: .leading, spacing: 10) {
                                // 작성자 정보 (SNS 출처 배지 제거 완료)
                                HStack {
                                    Image(systemName: firstReview.authorAvatar)
                                        .font(.system(size: 20))
                                        .foregroundStyle(.orange)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(firstReview.authorName)
                                            .font(.system(size: 13, weight: .bold))
                                        Text("\(r.address) • \(firstReview.visitDate)")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }

                                // 리뷰 본문 내용
                                Text(firstReview.content)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.primary)

                                Divider()

                                // 하단 맛집 간략 정보 (상세페이지로 이동하여 우측 상단 + 버튼으로 저장)
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(r.name)
                                            .font(.system(size: 14, weight: .bold))
                                        HStack(spacing: 4) {
                                            Text(r.category.rawValue)
                                                .font(.system(size: 11))
                                                .foregroundStyle(.orange)
                                            Text("★ \(String(format: "%.1f", r.baseRating))")
                                                .font(.system(size: 11, weight: .semibold))
                                                .monospacedDigit()
                                                .foregroundStyle(.orange)
                                        }
                                    }

                                    Spacer()

                                    // 상세페이지 진입 유도 안내 (저장은 상세페이지 상단 + 버튼에서 진행)
                                    HStack(spacing: 4) {
                                        Text("상세보기")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.secondary)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(Color.gray.opacity(0.6))
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
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.04), radius: 5, x: 0, y: 2)
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelectRestaurant(r)
                            }
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        // MARK: 당겨서 새로고침 (.refreshable 비즈니스 로직 연동)
        .refreshable {
            await viewModel.refreshFeed()
        }
    }
}

#Preview("홈 피드 화면 - 라이트") {
    HomeFeedView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
    .preferredColorScheme(.light)
}

#Preview("홈 피드 화면 - 다크") {
    HomeFeedView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
    .preferredColorScheme(.dark)
}
