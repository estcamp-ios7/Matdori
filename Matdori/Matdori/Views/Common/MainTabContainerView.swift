//
//  MainTabContainerView.swift
//  project2
//
//  상위 ContentView로부터 탭 전환 분기 책임을 분리한 전담 서브뷰
//

import SwiftUI

// MARK: - 메인 탭 컨텐츠 전환 전담 서브뷰
struct MainTabContainerView: View {
    // MARK: 맛집 비즈니스 로직 및 필터 상태를 공유하는 뷰모델
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 앱 전역 네비게이션 및 시트 상태 모델
    @Bindable var navState: AppNavigationState

    var body: some View {
        // 현재 선택된 탭(navState.selectedTab)에 따라 분기 렌더링
        Group {
            switch navState.selectedTab {
            case .map:
                // 1. 주변 맛집 지도 탐색 화면
                NearbyMapView(viewModel: viewModel)

            case .feed:
                // 2. 숨은 맛집 발견 피드 화면
                HomeFeedView(
                    viewModel: viewModel,
                    navigationPath: $navState.feedNavigationPath,
                    scrollToTopTrigger: navState.feedScrollToTopTrigger
                )

            case .myPage:
                // 3. 나의 맛집 리스트 화면
                MyRestaurantListView(
                    viewModel: viewModel,
                    onSelectRestaurant: { restaurant in
                        // 나의 맛집 선택 시 나만의 별점/메모 상세 모달 오픈
                        navState.openMyRestaurantDetail(for: restaurant)
                    }
                )
            }
        }
        // 전체 화면 공간을 가득 채우도록 프레임 설정
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 프리뷰
#Preview("메인 탭 컨테이너 - 라이트") {
    MainTabContainerView(
        viewModel: RestaurantViewModel(),
        navState: AppNavigationState()
    )
    .preferredColorScheme(.light)
}

#Preview("메인 탭 컨테이너 - 다크") {
    MainTabContainerView(
        viewModel: RestaurantViewModel(),
        navState: AppNavigationState()
    )
    .preferredColorScheme(.dark)
}
