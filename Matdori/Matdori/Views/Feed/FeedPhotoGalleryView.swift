//
//  FeedPhotoGalleryView.swift
//  project2
//
//  피드 게시글 상세 화면의 방문자 실제 음식 사진 및 스마트 갤러리 서브뷰
//  (사진 원본 가로세로 비율 최적화: scaledToFill + maxHeight: 240 제한)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 음식 사진 스마트 갤러리 뷰
struct FeedPhotoGalleryView: View {
    // MARK: 다크모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 상세 식당 및 리뷰 데이터
    let restaurant: Restaurant
    let review: CommunityReview

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: 리뷰에 등록된 실제 음식 사진이 존재하는 경우 (와이드~정방형 원본 비율 대응)
            if let photoName = review.photoName,
               let uiImage = UIImage(named: photoName) {
                photoCardView(image: uiImage)
            } else {
                // MARK: 첨부 사진이 없는 경우 깔끔한 카테고리 대표 컴팩트 배너 제공
                emptyPhotoFallbackBanner
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 원본 비율 최적화 블로그 스타일 사진 카드
    private func photoCardView(image: UIImage) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 240) // 가로 비율을 살리면서 화면 세로를 과도하게 차지하지 않도록 240pt 제한
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14))

            // 우하단 원본 사진 인증 배지 (가독성을 위한 반투명 캡슐 배지)
            HStack(spacing: 4) {
                Image(systemName: "camera.fill")
                    .font(.caption2)
                Text("방문자 촬영 사진")
                    .font(.caption2.weight(.medium))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.6))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .padding(10)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 240)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - [헬퍼 서브뷰] 사진 미등록 시 표시되는 카테고리 대표 컴팩트 배너
    private var emptyPhotoFallbackBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.opacity(colorScheme == .dark ? 0.25 : 0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: restaurant.category.iconName)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(restaurant.category.rawValue) 전문점 • \(restaurant.name)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("작성자가 등록한 사진이 없습니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.accentColor.opacity(0.15), lineWidth: 1)
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

#Preview("피드 사진 갤러리 - 사진 미등록 (다크)") {
    FeedPhotoGalleryView(
        restaurant: RestaurantViewModel().restaurants[0],
        review: RestaurantViewModel().restaurants[0].reviews[1]
    )
    .padding()
    .preferredColorScheme(.dark)
}
