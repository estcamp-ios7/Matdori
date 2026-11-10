//
//  FeedPhotoGalleryView.swift
//  project2
//
//  피드 게시글 상세 화면의 2분할 대표 메뉴 컷 & 음식 갤러리 서브뷰
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 음식 사진 갤러리 뷰
struct FeedPhotoGalleryView: View {
    // MARK: 시스템 라이트/다크모드 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 카테고리 심볼 표출용 식당 모델
    let restaurant: Restaurant

    // MARK: 첨부 사진이 포함된 커뮤니티 리뷰 모델
    let review: CommunityReview

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 갤러리 섹션 타이틀
            Text("음식 사진 갤러리 (2)")
                .font(.system(size: 14, weight: .bold))

            // 좌우 2분할 사진 카드 배치
            HStack(spacing: 10) {
                // 1. 대표 메뉴 컷 카드
                photoCard(index: 1, title: "대표 메뉴 컷")

                // 2. 매장 및 상차림 컷 카드
                photoCard(index: 2, title: "매장/상차림 컷")
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 개별 사진 카드 빌더
    @ViewBuilder
    private func photoCard(index: Int, title: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            // 실제 에셋 카탈로그에 사진이 존재하는 경우 이미지 렌더링
            if let photoName = review.photoName, UIImage(named: photoName) != nil {
                Image(photoName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .clipped()
            } else {
                // 사진 에셋이 없을 때 사용하는 웜톤 그라데이션 플레이스홀더
                LinearGradient(
                    colors: index == 1
                        ? [Color(red: 0.95, green: 0.68, blue: 0.32), Color(red: 0.82, green: 0.44, blue: 0.18)]
                        : [Color(red: 0.93, green: 0.60, blue: 0.28), Color(red: 0.78, green: 0.38, blue: 0.14)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // 중앙 음식 카테고리 심볼 아이콘
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
            }

            // 좌하단 사진 캡션 배지
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.45))
                .clipShape(Capsule())
                .padding(8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            // 카드 테두리 선
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.06), lineWidth: 1)
        )
        // 입체감을 위한 그림자 효과
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 프리뷰
#Preview("피드 사진 갤러리 - 라이트") {
    FeedPhotoGalleryView(
        restaurant: RestaurantViewModel().restaurants[0],
        review: RestaurantViewModel().restaurants[0].reviews[0]
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("피드 사진 갤러리 - 다크") {
    FeedPhotoGalleryView(
        restaurant: RestaurantViewModel().restaurants[0],
        review: RestaurantViewModel().restaurants[0].reviews[0]
    )
    .padding()
    .preferredColorScheme(.dark)
}
