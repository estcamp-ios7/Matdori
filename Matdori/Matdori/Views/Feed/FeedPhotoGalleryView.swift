//
//  FeedPhotoGalleryView.swift
//  project2
//
//  피드 게시글 상세 화면의 음식 사진 및 카테고리 갤러리 서브뷰 (블로그 리뷰 스타일 & Apple HIG 규격화)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 음식 사진 갤러리 뷰 (스마트 동적 렌더링)
struct FeedPhotoGalleryView: View {
    // MARK: 시스템 라이트/다크모드 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 카테고리 심볼 표출용 식당 모델
    let restaurant: Restaurant

    // MARK: 첨부 사진이 포함된 커뮤니티 리뷰 모델
    let review: CommunityReview

    // MARK: 실제 이미지 에셋 존재 여부 연산 프로퍼티
    private var hasActualPhoto: Bool {
        guard let photoName = review.photoName else { return false }
        return UIImage(named: photoName) != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // MARK: 갤러리 헤더 타이틀 (Apple HIG Semantic Headline)
            HStack {
                Text(hasActualPhoto ? "방문 인증 사진" : "메뉴 카테고리")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if hasActualPhoto {
                    Text("1장")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: 사진 유무에 따른 스마트 카드 렌더링
            if let photoName = review.photoName, let uiImage = UIImage(named: photoName) {
                // 실제 음식 사진이 등록되어 있을 때: 블로그 리뷰 스타일 적응형 카드
                actualPhotoCard(image: uiImage)
            } else {
                // 사진 에셋이 없을 때: 본문 가독성을 살리는 컴팩트 웜톤 배너
                categoryBannerCard
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 실제 인증 사진 카드 (블로그 리뷰 스타일: 원본 비율 보존 + 최대 높이 240pt 제한)
    private func actualPhotoCard(image: UIImage) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 240)
                .clipped()

            // 사진 하단 반투명 그라데이션 오버레이
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )

            // 좌하단 사진 안내 캡슐 배지 (HIG Semantic Caption2 Bold)
            HStack(spacing: 6) {
                Image(systemName: "camera.fill")
                    .font(.caption2)
                    .symbolRenderingMode(.hierarchical)
                Text("\(restaurant.name) • 방문 인증 컷")
                    .font(.caption2.weight(.bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.45))
            .clipShape(Capsule())
            .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 240)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 6, x: 0, y: 3)
    }

    // MARK: - [헬퍼 서브뷰] 사진 미등록 시 컴팩트 카테고리 배너 (높이 90pt)
    private var categoryBannerCard: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.68, blue: 0.32).opacity(colorScheme == .dark ? 0.35 : 0.25),
                    Color(red: 0.82, green: 0.44, blue: 0.18).opacity(colorScheme == .dark ? 0.45 : 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 14) {
                Image(systemName: restaurant.category == .dessert ? "birthday.cake.fill" : "fork.knife")
                    .font(.title)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.orange)
                    .padding(12)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(restaurant.category.rawValue) 전문점")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)

                    Text("\(restaurant.name)의 정갈한 메뉴를 만나보세요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.orange.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - 프리뷰
#Preview("피드 사진 갤러리 - 실제 사진 있음 (라이트)") {
    FeedPhotoGalleryView(
        restaurant: RestaurantViewModel().restaurants[0],
        review: RestaurantViewModel().restaurants[0].reviews[0]
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("피드 사진 갤러리 - 실제 사진 있음 (다크)") {
    FeedPhotoGalleryView(
        restaurant: RestaurantViewModel().restaurants[0],
        review: RestaurantViewModel().restaurants[0].reviews[0]
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("피드 사진 갤러리 - 사진 미등록 (라이트)") {
    FeedPhotoGalleryView(
        restaurant: RestaurantViewModel().restaurants[0],
        review: RestaurantViewModel().restaurants[0].reviews[1]
    )
    .padding()
    .preferredColorScheme(.light)
}
