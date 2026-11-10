//
//  MyRestaurantRecordSection.swift
//  project2
//
//  나의 맛집 상세 화면의 나만의 별점 평가 및 개인 메모 편집 섹션 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 나의 맛집 기록 (별점 및 메모) 편집 섹션 (Apple HIG 준수)
struct MyRestaurantRecordSection: View {
    // MARK: 시스템 다크모드 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 대상 식당 식별자 ID
    let restaurantId: UUID

    // MARK: 내가 준 별점 바인딩 상태
    @Binding var currentMyRating: Int?

    // MARK: 내가 작성한 메모 바인딩 상태
    @Binding var currentMyNote: String

    // MARK: 별점 변경 시 뷰모델 동기화 콜백
    var onRatingChange: (Int?) -> Void

    // MARK: 메모 변경 시 뷰모델 동기화 콜백
    var onNoteChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // MARK: 1. 헤더: 북마크 아이콘 + 현재 평점 텍스트 (Semantic Headline & Subheadline)
            HStack {
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(Color.orange)

                Text("나만의 맛집 기록")
                    .font(.headline)

                Spacer()

                if let rating = currentMyRating {
                    Text("\(rating) / 5점")
                        .font(.subheadline.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(Color.orange)
                } else {
                    Text("별점을 선택해주세요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: 2. 나만의 별점 부여 버튼 (Apple HIG 44x44pt 터치 타깃 보장)
            VStack(alignment: .leading, spacing: 4) {
                Text("나의 별점")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                                if currentMyRating == star {
                                    currentMyRating = nil
                                    onRatingChange(nil)
                                } else {
                                    currentMyRating = star
                                    onRatingChange(star)
                                }
                            }
                        } label: {
                            Image(systemName: (currentMyRating != nil && star <= (currentMyRating ?? 0)) ? "star.fill" : "star")
                                .font(.title)
                                .foregroundStyle((currentMyRating != nil && star <= (currentMyRating ?? 0)) ? Color.orange : Color.gray.opacity(0.35))
                                .frame(width: 44, height: 44) // HIG 최소 터치 규격 44x44pt 보장
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    // 별점이 매겨져 있을 때 초기화 버튼 (터치 높이 보장)
                    if currentMyRating != nil {
                        Button {
                            withAnimation {
                                currentMyRating = nil
                                onRatingChange(nil)
                            }
                        } label: {
                            Text("초기화")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .frame(height: 36)
                                .background(Color.gray.opacity(0.15))
                                .clipShape(Capsule())
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 6)
                    }
                }
            }

            Divider()
                .padding(.vertical, 4)

            // MARK: 3. 나만의 메모 작성 다중 행 텍스트필드 (HIG 텍스트 필드 규격)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "square.and.pencil")
                        .font(.caption)
                        .foregroundStyle(Color.orange)

                    Text("나만의 메모")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    // 글자 수 실시간 표출 (Semantic Caption2)
                    if !currentMyNote.isEmpty {
                        Text("\(currentMyNote.count)자")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                TextField("나만의 맛집 팁, 추천 메뉴, 재방문 의사 등을 자유롭게 메모해보세요.", text: $currentMyNote, axis: .vertical)
                    .lineLimit(6...10)
                    .font(.body)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .onChange(of: currentMyNote) { _, newValue in
                        // 메모 변경 시 뷰모델로 즉시 저장 위임
                        onNoteChange(newValue)
                    }
            }
        }
        .padding(16)
        .background(Color.orange.opacity(colorScheme == .dark ? 0.15 : 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - 프리뷰
#Preview("나의 맛집 기록 섹션 - 라이트") {
    @Previewable @State var rating: Int? = 4
    @Previewable @State var note: String = "양념이 감칠맛 나고 정말 맛있음! 재방문 의사 100%"
    MyRestaurantRecordSection(
        restaurantId: UUID(),
        currentMyRating: $rating,
        currentMyNote: $note,
        onRatingChange: { _ in },
        onNoteChange: { _ in }
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("나의 맛집 기록 섹션 - 다크") {
    @Previewable @State var rating: Int? = 5
    @Previewable @State var note: String = "다크모드에서도 가독성이 우수합니다."
    MyRestaurantRecordSection(
        restaurantId: UUID(),
        currentMyRating: $rating,
        currentMyNote: $note,
        onRatingChange: { _ in },
        onNoteChange: { _ in }
    )
    .padding()
    .preferredColorScheme(.dark)
}
