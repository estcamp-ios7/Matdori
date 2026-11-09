//
//  ContentView.swift
//  project2
//
//  Created by Jang Ho on 11/5/26.
//  메인 루트 컨테이너 뷰 (MVVM 아키텍처 적용, 다크모드 대응)
//

import SwiftUI

// MARK: - 메인 컨테이너 뷰
struct ContentView: View {
    // MARK: 다크모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 맛집 메인 뷰모델 인스턴스
    @State private var viewModel = RestaurantViewModel()

    // MARK: 현재 선택된 탭 상태 (기본값: 주변 맛집 지도)
    @State private var selectedTab: AppTab = .map

    // MARK: 주변 맛집 탐색 상세페이지 대상 식당 상태
    @State private var selectedExploreRestaurant: Restaurant? = nil

    // MARK: 나의 맛집 상세페이지 대상 식당 상태
    @State private var selectedMyRestaurant: Restaurant? = nil

    // MARK: 피드 네비게이션 경로 (상세 게시글에서 피드 탭 재선택 시 Pop to Root 처리)
    @State private var feedNavigationPath = NavigationPath()

    // MARK: 피드 메인 화면 최상단 스크롤 트리거 ID
    @State private var feedScrollToTopTrigger = UUID()

    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: 1. 메인 탭 컨텐츠 뷰 전환
            Group {
                switch selectedTab {
                case .map:
                    // 주변 맛집 화면 (지도 핀 및 리스트 탐색)
                    NearbyMapView(
                        viewModel: viewModel,
                        onSelectRestaurant: { restaurant in
                            selectedExploreRestaurant = restaurant
                        }
                    )
                case .feed:
                    // 숨은 맛집 발견 피드 화면 (방문자 솔직 리뷰 피드, 새로고침 및 피드 탭 재선택 Pop to Root 지원)
                    HomeFeedView(
                        viewModel: viewModel,
                        onSelectRestaurant: { restaurant in
                            selectedExploreRestaurant = restaurant
                        },
                        navigationPath: $feedNavigationPath,
                        scrollToTopTrigger: feedScrollToTopTrigger
                    )
                case .myPage:
                    // 나의 맛집 리스트 화면 (단일 리스트 및 별점 노출, 스와이프 삭제)
                    MyRestaurantListView(
                        viewModel: viewModel,
                        onSelectRestaurant: { restaurant in
                            selectedMyRestaurant = restaurant
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // MARK: 2. 하단 커스텀 플로팅 탭바
            CustomTabBar(
                selectedTab: $selectedTab,
                onReselectTab: { tab in
                    if tab == .feed {
                        if !feedNavigationPath.isEmpty {
                            // FeedPostDetailView 등 상세 게시글에 있는 경우: 즉시 홈 피드 메인으로 복귀 (Pop to Root)
                            feedNavigationPath = NavigationPath()
                        } else {
                            // 이미 홈 피드 메인 화면에 있는 경우: 최상단으로 스크롤 이동
                            feedScrollToTopTrigger = UUID()
                        }
                    }
                }
            )
                .padding(.bottom, 12)
        }
        // 주변 맛집 탐색 상세페이지 모달 시트
        .sheet(item: $selectedExploreRestaurant) { restaurant in
            RestaurantDetailView(
                viewModel: viewModel,
                restaurant: restaurant
            )
        }
        // 나의 맛집 상세페이지 모달 시트 (나만의 별점 및 메모 관리)
        .sheet(item: $selectedMyRestaurant) { restaurant in
            MyRestaurantDetailView(
                viewModel: viewModel,
                restaurant: restaurant
            )
        }
    }
}

#Preview("라이트 모드") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("다크 모드") {
    ContentView()
        .preferredColorScheme(.dark)
}
