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

    // MARK: 상세페이지를 띄울 대상 식당 상태
    @State private var selectedDetailRestaurant: Restaurant? = nil

    // MARK: '나의 맛집 리스트'에서 상세페이지로 진입했는지 여부 (포스트잇 요구사항 분기 플래그)
    @State private var detailOpenedFromMyList: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: 1. 메인 탭 컨텐츠 뷰 전환
            Group {
                switch selectedTab {
                case .feed:
                    // 홈 피드 화면 (다른 사용자 후기 탐색 및 탭하여 상세페이지 진입 후 +버튼 저장)
                    HomeFeedView(
                        viewModel: viewModel,
                        onSelectRestaurant: { restaurant in
                            selectedDetailRestaurant = restaurant
                            detailOpenedFromMyList = false
                        }
                    )
                case .map:
                    // 주변 맛집 화면 (지도 핀 및 리스트 탐색)
                    NearbyMapView(
                        viewModel: viewModel,
                        onSelectRestaurant: { restaurant in
                            selectedDetailRestaurant = restaurant
                            detailOpenedFromMyList = false
                        }
                    )
                case .myPage:
                    // 나의 맛집 리스트 화면 (단일 리스트 및 별점 노출, 스와이프 삭제)
                    MyRestaurantListView(
                        viewModel: viewModel,
                        onSelectRestaurant: { restaurant in
                            selectedDetailRestaurant = restaurant
                            detailOpenedFromMyList = true
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // MARK: 2. 하단 커스텀 플로팅 탭바
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 12)
        }
        // 식당 상세페이지 모달 시트
        .sheet(item: $selectedDetailRestaurant) { restaurant in
            RestaurantDetailView(
                viewModel: viewModel,
                restaurant: restaurant,
                openedFromMyList: detailOpenedFromMyList
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
