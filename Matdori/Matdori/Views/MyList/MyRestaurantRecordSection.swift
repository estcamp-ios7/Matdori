//
//  MyRestaurantRecordSection.swift
//  project2
//
//  나의 맛집 상세 화면의 나의 별점 평가 및 개인 메모 편집 섹션 (Apple HIG 규격화)
//  (FocusState 기반 키보드 제어 및 방문 상태 단일 토글 버튼 탑재)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 나의 맛집 기록 (방문상태, 별점 및 메모) 편집 섹션 (Apple HIG 준수)
struct MyRestaurantRecordSection: View {
    // MARK: 시스템 다크모드 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 대상 식당 식별자 ID
    let restaurantId: UUID

    // MARK: 방문 상태 바인딩 (가고 싶은 곳 vs 다녀온 곳)
    @Binding var currentVisitStatus: MyVisitStatus

    // MARK: 내가 준 별점 바인딩 상태
    @Binding var currentMyRating: Int?

    // MARK: 내가 작성한 메모 바인딩 상태
    @Binding var currentMyNote: String

    // MARK: 별점 변경 시 뷰모델 동기화 콜백
    var onRatingChange: (Int?) -> Void

    // MARK: 메모 변경 시 뷰모델 동기화 콜백
    var onNoteChange: (String) -> Void

    // MARK: 텍스트필드 키보드 포커스 상태 (Apple HIG FocusState)
    @FocusState private var isNoteFocused: Bool

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

            // MARK: 2. 방문 상태 토글 (단일 버튼 통합 & MyRestaurantListView 스타일의 SF Symbol 적용)
            VStack(alignment: .leading, spacing: 6) {
                Text("방문 여부")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        currentVisitStatus = (currentVisitStatus == .visited ? .wantToGo : .visited)
                    }
                } label: {
                    HStack(spacing: 10) {
                        // SF Symbol 아이콘 (다녀온 곳: checkmark.seal.fill, 가고 싶은 곳: bookmark.fill)
                        Image(systemName: currentVisitStatus == .visited ? "checkmark.seal.fill" : "bookmark.fill")
                            .font(.headline)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(currentVisitStatus == .visited ? Color.white : Color.orange)

                        // 방문 상태 텍스트 및 서브 안내
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentVisitStatus.rawValue)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(currentVisitStatus == .visited ? Color.white : Color.primary)

                            Text(currentVisitStatus == .visited ? "실제 방문을 완료한 맛집입니다" : "아직 방문 전 찜해둔 맛집입니다")
                                .font(.caption2)
                                .foregroundStyle(currentVisitStatus == .visited ? Color.white.opacity(0.85) : Color.secondary)
                        }

                        Spacer()

                        // 상호 전환 안내 순환 아이콘
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(currentVisitStatus == .visited ? Color.white.opacity(0.8) : Color.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48) // Apple HIG 최소 터치 높이 44pt 보장
                    .background(
                        currentVisitStatus == .visited
                        ? Color.orange
                        : Color(uiColor: .secondarySystemGroupedBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                currentVisitStatus == .visited
                                ? Color.clear
                                : (colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)),
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }

            Divider()
                .padding(.vertical, 2)

            // MARK: 3. 나만의 별점 부여 버튼 (Apple HIG 44x44pt 터치 타깃 보장)
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
                                    // 별점을 매기면 자동으로 '다녀온 곳'으로 전환
                                    currentVisitStatus = .visited
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
                .padding(.vertical, 2)

            // MARK: 4. 나만의 메모 작성 다중 행 텍스트필드 (HIG 텍스트 필드 규격 및 FocusState)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "square.and.pencil")
                        .font(.caption)
                        .foregroundStyle(Color.orange)

                    Text("나만의 메모")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    // 키보드가 활성화되었을 때 키보드 내리기 버튼 제공 (HIG 인터랙션)
                    if isNoteFocused {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isNoteFocused = false
                            }
                        } label: {
                            HStack(spacing: 2) {
                                Image(systemName: "keyboard.chevron.compact.down")
                                    .font(.caption2)
                                Text("완료")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(Color.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.12))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    } else if !currentMyNote.isEmpty {
                        // 글자 수 실시간 표출 (Semantic Caption2)
                        Text("\(currentMyNote.count)자")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                TextField("나만의 맛집 팁, 추천 메뉴, 재방문 의사 등을 자유롭게 메모해보세요.", text: $currentMyNote, axis: .vertical)
                    .lineLimit(5...8)
                    .font(.body)
                    .focused($isNoteFocused) // FocusState 키보드 포커스 바인딩
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isNoteFocused
                                ? Color.orange
                                : (colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)),
                                lineWidth: isNoteFocused ? 1.5 : 1
                            )
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
    @Previewable @State var status: MyVisitStatus = .visited
    @Previewable @State var rating: Int? = 4
    @Previewable @State var note: String = "양념이 감칠맛 나고 정말 맛있음! 재방문 의사 100%"
    MyRestaurantRecordSection(
        restaurantId: UUID(),
        currentVisitStatus: $status,
        currentMyRating: $rating,
        currentMyNote: $note,
        onRatingChange: { _ in },
        onNoteChange: { _ in }
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("나의 맛집 기록 섹션 - 다크") {
    @Previewable @State var status: MyVisitStatus = .wantToGo
    @Previewable @State var rating: Int? = 5
    @Previewable @State var note: String = "다크모드에서도 가독성이 우수합니다."
    MyRestaurantRecordSection(
        restaurantId: UUID(),
        currentVisitStatus: $status,
        currentMyRating: $rating,
        currentMyNote: $note,
        onRatingChange: { _ in },
        onNoteChange: { _ in }
    )
    .padding()
    .preferredColorScheme(.dark)
}
