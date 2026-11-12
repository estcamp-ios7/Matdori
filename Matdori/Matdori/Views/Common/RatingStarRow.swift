//
//  RatingStarRow.swift
//  project2
//
//  1~5점 별점을 소수점(반별 지원) 또는 정수 기준으로 렌더링하는 공통 재사용 컴포넌트 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [공통 컴포넌트] 1~5점 별점 렌더링 뷰 (Apple HIG 준수)
struct RatingStarRow: View {
    // MARK: 표시할 별점 (예: 4.8 또는 5.0)
    let rating: Double

    // MARK: 별 아이콘 폰트 크기
    var font: Font = .caption

    // MARK: 채워진 별 색상
    var activeColor: Color = Color.accentColor

    // MARK: 빈 별 색상
    var inactiveColor: Color = Color.gray.opacity(0.35)

    // MARK: 별 사이 간격
    var spacing: CGFloat = 2

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...5, id: \.self) { index in
                starImage(for: index)
                    .font(font)
                    .foregroundStyle(starColor(for: index))
            }
        }
    }

    // MARK: - [헬퍼 함수] 인덱스별 SF Symbol 별 모양 결정
    private func starImage(for index: Int) -> Image {
        if Double(index) <= rating {
            return Image(systemName: "star.fill")
        } else if Double(index) - 0.5 <= rating {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }

    // MARK: - [헬퍼 함수] 인덱스별 색상 결정
    private func starColor(for index: Int) -> Color {
        if Double(index) - 0.5 <= rating {
            return activeColor
        } else {
            return inactiveColor
        }
    }
}

// MARK: - 프리뷰
#Preview("별점 뷰 - 다양한 점수") {
    VStack(spacing: 12) {
        RatingStarRow(rating: 4.8)
        RatingStarRow(rating: 3.5, font: .subheadline)
        RatingStarRow(rating: 5.0, font: .caption2)
        RatingStarRow(rating: 2.0)
    }
    .padding()
}
