//
//  ContentView.swift
//  project2
//
//  Created by Jang Ho on 11/5/26.
//  메인 루트 컨테이너 뷰 (상태 캡슐화 모델 적용 및 서브뷰 분리)
//

import SwiftUI

// MARK: - 메인 루트 컨테이너 뷰
struct ContentView: View {
    // MARK: 시스템 라이트/다크 모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 맛집 메인 데이터 관리 뷰모델
    @State private var viewModel = RestaurantViewModel()

    // MARK: 앱 전역 네비게이션 및 시트 상태 캡슐화 모델
    @State private var navState = AppNavigationState()

    var body: some View {
        // 하단 정렬 기준의 루트 ZStack
        ZStack(alignment: .bottom) {
            // MARK: 1. 탭 컨텐츠 전환 전담 서브뷰
            MainTabContainerView(
                viewModel: viewModel,
                navState: navState
            )

            // MARK: 2. 하단 커스텀 플로팅 탭바 서브뷰
            CustomTabBar(
                selectedTab: $navState.selectedTab,
                onReselectTab: { tab in
                    // 활성화된 탭을 다시 눌렀을 때 Pop to Root 및 최상단 스크롤 인텐트 위임
                    navState.handleTabReselect(tab)
                }
            )
            // 홈 인디케이터와의 시각적 간격을 위해 하단 패딩 부여
            .padding(.bottom, 12)
        }
        // MARK: 3. 주변 맛집 탐색 상세 모달 시트 바인딩
        .sheet(item: $navState.selectedExploreRestaurant) { restaurant in
            RestaurantDetailView(
                viewModel: viewModel,
                restaurant: restaurant
            )
        }
        // MARK: 4. 나의 맛집 상세 모달 시트 바인딩 (나만의 별점 및 메모 기록 전용)
        .sheet(item: $navState.selectedMyRestaurant) { restaurant in
            MyRestaurantDetailView(
                viewModel: viewModel,
                restaurant: restaurant
            )
        }
    }
}

// MARK: - 프리뷰
#Preview("라이트 모드") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("다크 모드") {
    ContentView()
        .preferredColorScheme(.dark)
}
