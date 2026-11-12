//
//  RestaurantDetailView.swift
//  project2
//
//  식당 상세 정보, 대표 메뉴, 방문자 리뷰 목록 및 북마크 토스트 안내 화면 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [화면 컴포넌트] 식당 상세 정보 뷰 (Apple HIG 준수)
struct RestaurantDetailView: View {
    // MARK: 맛집 비즈니스 로직 및 북마크 저장 상태 뷰모델
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 상세 정보를 표시할 식당 데이터 모델
    let restaurant: Restaurant

    // MARK: 나의 맛집 저장 완료 플로팅 토스트 표시 플래그
    @State private var showAddedToast = false

    // MARK: 이미 등록된 식당 안내 플로팅 토스트 표시 플래그
    @State private var showAlreadySavedToast = false

    // MARK: '더보기' 클릭 시 전체 리뷰 내용을 표시할 대상 리뷰 모델 (시트 바인딩)
    @State private var selectedReview: CommunityReview?

    var body: some View {
        // 상단 정렬 플로팅 토스트 HUD를 위한 루트 ZStack
        ZStack(alignment: .top) {
            // 본체 스크롤 컨테이너
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: 1. 식당 위치 지도 와이어프레임 뷰
                    topMapWireframeView
                        .padding(.horizontal, 16)

                    // MARK: 2. 식당 기본 정보 헤더 (식당명, 카테고리 태그, 별점 평균)
                    basicInfoHeader
                        .padding(.horizontal, 16)

                    Divider()
                        .padding(.horizontal, 16)

                    // MARK: 3. 식당 영업시간, 전화번호, 주소, 주차 정보 섹션
                    RestaurantInfoSection(restaurant: restaurant)
                        .padding(.horizontal, 16)

                    // MARK: 4. 식당 메뉴 및 가격표 섹션
                    RestaurantMenuSection(restaurant: restaurant)
                        .padding(.horizontal, 16)

                    // MARK: 5. 방문자 진솔 리뷰 목록 섹션
                    reviewsSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .navigationTitle("식당 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 상단 우측: '나의 맛집' 북마크 추가 액션 버튼
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // 중복 저장 여부 검증 및 토스트 노출 분기
                        if viewModel.saveRestaurant(id: restaurant.id) {
                            showAlreadySavedToast = false
                            showAddedToast = true
                            Task {
                                try? await Task.sleep(for: .seconds(2.2))
                                showAddedToast = false
                            }
                        } else {
                            showAddedToast = false
                            showAlreadySavedToast = true
                            Task {
                                try? await Task.sleep(for: .seconds(2.2))
                                showAlreadySavedToast = false
                            }
                        }
                    } label: {
                        // Apple HIG 권장 접근성 라벨 및 44x44pt 최소 터치 영역 보장
                        Label("추가", systemImage: "plus")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.accentColor)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                }
            }
            // 리뷰 전체보기 바텀 시트 바인딩
            .sheet(item: $selectedReview) { review in
                ReviewFullContentSheet(restaurant: restaurant, review: review)
                    .presentationDetents([.medium, .large])
            }

            // MARK: 6. 상단 플로팅 토스트 인디케이터 (Apple HIG Material Glass HUD)
            if showAddedToast {
                toastCapsule(
                    title: "나의 맛집에 추가했어요",
                    systemImage: "checkmark.circle.fill",
                    iconColor: Color.accentColor
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            } else if showAlreadySavedToast {
                toastCapsule(
                    title: "이미 저장된 가게입니다",
                    systemImage: "info.circle.fill",
                    iconColor: .secondary
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showAddedToast)
        .animation(.easeInOut(duration: 0.25), value: showAlreadySavedToast)
    }

    // MARK: - [헬퍼 서브뷰] 다크모드/라이트모드 자동 대응 플로팅 토스트 캡슐
    private func toastCapsule(title: String, systemImage: String, iconColor: Color) -> some View {
        HStack(spacing: 8) {
            // 안내 아이콘
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(iconColor)

            // 안내 타이틀 텍스트
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial) // 라이트/다크 모드 적응형 프로스트 글래스
        .clipShape(Capsule())
        .overlay(
            // 다크모드 배경에서도 경계선이 명확하도록 돕는 미세 스트로크
            Capsule()
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 4)
        .padding(.top, 8)
    }

    // MARK: - [헬퍼 서브뷰] 상단 지도 플레이스홀더 영역
    private var topMapWireframeView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                .frame(height: 180)

            VStack(spacing: 8) {
                Image(systemName: "map")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("지도 영역: \(restaurant.name)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 식당 기본 정보 헤더 (식당명, 카테고리 칩, 5점 별점 요약)
    private var basicInfoHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 식당 명칭 및 카테고리 캡슐
            HStack(alignment: .center) {
                Text(restaurant.name)
                    .font(.title2.weight(.bold))
                    .lineLimit(2)

                Spacer(minLength: 12)

                Text(restaurant.category.rawValue)
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor.opacity(0.14))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
            }

            // 1~5점 별점 시각화 (RatingStarRow 재사용 컴포넌트) 및 평균 평점 수치 표출
            HStack(spacing: 6) {
                RatingStarRow(rating: restaurant.baseRating, font: .caption)

                Text(String(format: "%.1f", restaurant.baseRating))
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(Color.accentColor)

                Text("방문자 평가 평균")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 방문자 리뷰 섹션 (최다 추천 리뷰 O(N) 단일 계산 캐싱)
    private var reviewsSection: some View {
        let topReview = restaurant.reviews.max(by: { $0.helpfulCount < $1.helpfulCount })

        return VStack(alignment: .leading, spacing: 12) {
            // 섹션 헤더 (총 리뷰 수 표출)
            HStack(alignment: .firstTextBaseline) {
                Text("진솔한 방문자 리뷰")
                    .font(.title3.weight(.bold))

                Text("\(restaurant.reviews.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()
            }

            // '도움이 됐어요' 최다 추천을 받은 대표 리뷰 강조 표시
            if let representativeReview = topReview {
                Text("가장 도움이 된 리뷰")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                DetailReviewCardView(
                    review: representativeReview,
                    isFeatured: true,
                    onSelectReview: {
                        selectedReview = representativeReview
                    }
                )
            }

            // 나머지 일반 리뷰 목록 렌더링 (topReview.id 재사용으로 O(N^2) 반복 탐색 방지)
            ForEach(restaurant.reviews) { review in
                if review.id != topReview?.id {
                    DetailReviewCardView(
                        review: review,
                        isFeatured: false,
                        onSelectReview: {
                            selectedReview = review
                        }
                    )
                }
            }
        }
    }
}

// MARK: - [서브뷰 컴포넌트] 식당 리뷰 카드 (2줄 초과 말줄임 여부 동적 감지)
private struct DetailReviewCardView: View {
    // MARK: 표시 대상 리뷰 모델
    let review: CommunityReview

    // MARK: 추천 리뷰 하이라이트 여부
    let isFeatured: Bool

    // MARK: '더보기' 버튼 클릭 시 바텀 시트 오픈 콜백
    let onSelectReview: () -> Void

    // MARK: 텍스트 본문이 2줄을 초과해 잘렸는지 여부 상태
    @State private var isTruncated: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 상단 행: 작성자 아바타, 이름, 방문일, 평점
            HStack {
                Image(systemName: review.authorAvatar)
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)

                Text(review.authorName)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text(review.visitDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(Color.accentColor)
                Text(String(format: "%.1f", review.rating))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.accentColor)
            }

            // 리뷰 본문: 2줄 제한 렌더링 및 동적 높이 비교를 통한 Truncation 감지
            Text(review.content)
                .font(.body)
                .lineSpacing(3)
                .lineLimit(2)
                .background(
                    GeometryReader { displayedGeo in
                        Text(review.content)
                            .font(.body)
                            .lineSpacing(3)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .hidden()
                            .background(
                                GeometryReader { fullGeo in
                                    Color.clear.preference(
                                        key: TruncatedTextPreferenceKey.self,
                                        value: fullGeo.size.height > displayedGeo.size.height + 1
                                    )
                                }
                            )
                    }
                )
                .onPreferenceChange(TruncatedTextPreferenceKey.self) { truncated in
                    isTruncated = truncated
                }

            // 하단 행: 도움이 됐어요 카운트 + 2줄 초과 시에만 '더보기' 버튼 노출
            HStack {
                Label("\(review.helpfulCount)", systemImage: "hand.thumbsup.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                Text("도움이 됐어요")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // 실제 2줄을 초과하는 긴 리뷰인 경우에만 더보기 버튼 노출
                if isTruncated {
                    Button("더보기") {
                        onSelectReview()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.gray)
                }
            }
        }
        .padding(14)
        .background(isFeatured ? Color.accentColor.opacity(0.08) : Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            // 하이라이트 대표 리뷰일 경우 액센트 컬러 테두리 스트로크
            if isFeatured {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            }
        }
    }
}

// MARK: - 텍스트 말줄임 감지 PreferenceKey
private struct TruncatedTextPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

// MARK: - [모달 서브뷰] 리뷰 전체보기 바텀 시트
private struct ReviewFullContentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let restaurant: Restaurant
    let review: CommunityReview
    @State private var isHelpful = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // 식당 명칭
                    Text(restaurant.name)
                        .font(.title3.weight(.bold))

                    // 작성자 정보 및 방문일
                    HStack {
                        Label(review.authorName, systemImage: review.authorAvatar)
                        Spacer()
                        Text(review.visitDate)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)

                    // 전체 리뷰 본문 텍스트
                    Text(review.content)
                        .font(.body)
                        .lineSpacing(6)

                    // '도움이 됐어요' 인터랙션 토글 버튼
                    Button {
                        isHelpful.toggle()
                    } label: {
                        Label(
                            isHelpful ? "도움이 됐어요 \(review.helpfulCount + 1)" : "도움이 됐어요 \(review.helpfulCount)",
                            systemImage: isHelpful ? "hand.thumbsup.fill" : "hand.thumbsup"
                        )
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
            .navigationTitle("리뷰 전체보기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 프리뷰
#Preview("식당 상세") {
    NavigationStack {
        RestaurantDetailView(
            viewModel: RestaurantViewModel(),
            restaurant: RestaurantViewModel().restaurants[0]
        )
    }
}
