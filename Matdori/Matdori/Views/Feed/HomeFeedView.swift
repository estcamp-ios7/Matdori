//
//  HomeFeedView.swift
//  project2
//
//  전라도 광주 지역 한정 방문자 리뷰 탐색 홈 피드 화면 (Apple HIG 규격화 & 피드 검색 바 탑재)
//  (성능 최적화: 당겨서 새로고침, LazyVStack 지연 로딩, 서브뷰 분리, 불필요한 바인딩 제거)
//

import SwiftUI

// MARK: - [메인 뷰 컴포넌트] 홈 피드 화면 (Apple HIG 준수)
struct HomeFeedView: View {
    // MARK: 시스템 라이트/다크모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 식당 데이터 및 필터 상태를 공유하는 맛집 뷰모델
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 피드 탭 재선택 시 Pop to Root 처리를 위한 NavigationPath 바인딩
    @Binding var navigationPath: NavigationPath

    // MARK: 피드 메인 최상단 스크롤을 위한 트리거 ID
    var scrollToTopTrigger: UUID = UUID()

    var body: some View {
        // 독립적인 네비게이션 스택 컨테이너
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    // MARK: 1. 상단 지역 인디케이터 배지 및 메인 타이틀 영역
                    headerView

                    // MARK: 2. 피드 전용 통합 검색 바 (식당, 리뷰, 메뉴, 작성자)
                    feedSearchBar

                    // MARK: 3. 광주 주요 상권 필터 바 서브뷰
                    FeedDistrictFilterBar(viewModel: viewModel)

                    // MARK: 4. 이웃들이 공유한 방문자 리뷰 피드 목록
                    feedCardListView
                }
                .padding(.bottom, 60)
            }
            // 항상 바운스 스크롤이 활성화되도록 보장
            .scrollBounceBehavior(.always)
            // 피드 당겨서 새로고침 액션 연동
            .refreshable {
                await viewModel.refreshFeed()
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            // 기본 네비게이션 바 숨김 처리
            .toolbar(.hidden, for: .navigationBar)
            // 리뷰 상세 화면으로의 네비게이션 목적지 등록
            .navigationDestination(for: UUID.self) { restaurantID in
                if let r = viewModel.restaurants.first(where: { $0.id == restaurantID }),
                   let firstReview = r.reviews.first {
                    FeedPostDetailView(
                        viewModel: viewModel,
                        restaurant: r,
                        review: firstReview
                    )
                }
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 피드 상단 헤더
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 지역 인디케이터 배지
            HStack(spacing: 6) {
                Image(systemName: "location.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.orange)

                Text("광주광역시 한정 피드")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.orange)

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.12))
            .clipShape(Capsule())

            // 피드 대표 타이틀 및 서브 타이틀 (Apple HIG Semantic Typography)
            VStack(alignment: .leading, spacing: 4) {
                Text("광주 맛집 피드 & 찐리뷰")
                    .font(.title2.weight(.bold))

                Text("전라도 광주 이웃들의 솔직한 실시간 방문 후기")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
    }

    // MARK: - [헬퍼 서브뷰] 피드 전용 검색 바 (Apple HIG 규격: 최소 터치 높이 44pt)
    private var feedSearchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.headline)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)

            TextField("식당, 리뷰 키워드, 메뉴, 작성자 검색", text: $viewModel.feedSearchQuery)
                .font(.subheadline)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !viewModel.feedSearchQuery.isEmpty {
                Button {
                    viewModel.feedSearchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    // MARK: - [헬퍼 서브뷰] 리뷰 카드 리스트 영역
    private var feedCardListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 섹션 헤더 (자치구명 및 식당 건수)
            HStack {
                Text("🔥 \(viewModel.selectedFeedDistrict == .all ? "광주 전체" : viewModel.selectedFeedDistrict.rawValue) 이웃 리뷰 피드")
                    .font(.headline)

                Spacer()

                Text("\(viewModel.filteredFeedRestaurants.count)곳")
                    .font(.subheadline.weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)

            // 리뷰 피드가 비어있을 때와 존재할 때의 분기 처리
            if viewModel.filteredFeedRestaurants.isEmpty {
                emptyFeedNoticeView
            } else {
                // [성능 최적화] LazyVStack 적용: 화면에 보이는 카드만 지연 인스턴스화
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredFeedRestaurants) { r in
                        if let firstReview = r.reviews.first {
                            NavigationLink(value: r.id) {
                                FeedReviewCardView(restaurant: r, review: firstReview)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 피드 비어있음 안내
    private var emptyFeedNoticeView: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: viewModel.feedSearchQuery.isEmpty ? "newspaper" : "magnifyingglass")
                .font(.system(size: 38))
                .foregroundStyle(.tertiary)

            if viewModel.feedSearchQuery.isEmpty {
                Text("아직 \(viewModel.selectedFeedDistrict.rawValue)에 등록된 리뷰가 없습니다.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Text("다른 자치구를 선택해보세요.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } else {
                Text("'\(viewModel.feedSearchQuery)' 검색 결과가 없습니다.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Text("다른 검색어나 메뉴명을 입력해보세요.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 180)
    }
}

// MARK: - 프리뷰
#Preview("홈 피드 화면 - 라이트") {
    @Previewable @State var path = NavigationPath()
    HomeFeedView(
        viewModel: RestaurantViewModel(),
        navigationPath: $path
    )
    .preferredColorScheme(.light)
}

#Preview("홈 피드 화면 - 다크") {
    @Previewable @State var path = NavigationPath()
    HomeFeedView(
        viewModel: RestaurantViewModel(),
        navigationPath: $path
    )
    .preferredColorScheme(.dark)
}
