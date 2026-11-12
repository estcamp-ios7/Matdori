//
//  AppNavigationState.swift
//  project2
//
//  앱 전역 네비게이션, 탭 선택, 모달 시트 상태 캡슐화 모델
//

import SwiftUI
import Observation

// MARK: - 앱 네비게이션 및 시트 전역 상태 모델
@Observable
final class AppNavigationState {
    // MARK: 현재 선택된 탭 (기본값: 주변 맛집 지도)
    var selectedTab: AppTab = .map

    // MARK: 나의 맛집 상세 모달 대상 식당 (nil일 경우 닫힘)
    var selectedMyRestaurant: Restaurant? = nil

    // MARK: 피드 탭 네비게이션 경로 스택 (Pop to Root 지원)
    var feedNavigationPath = NavigationPath()

    // MARK: 피드 메인 최상단 스크롤 트리거 ID
    var feedScrollToTopTrigger = UUID()

    // MARK: - 탭 재선택 핸들러 (Pop to Root & 최상단 스크롤 제어)
    func handleTabReselect(_ tab: AppTab) {
        // 피드 탭에서만 특정 동작 수행
        guard tab == .feed else { return }

        // 네비게이션 스택에 상세 페이지가 푸시되어 있는 경우
        if !feedNavigationPath.isEmpty {
            // 빈 경로를 대입하여 홈 피드 루트 화면으로 즉각 복귀
            feedNavigationPath = NavigationPath()
        } else {
            // 이미 피드 메인 화면에 있는 경우 새 UUID를 할당하여 스크롤 트리거 발동
            feedScrollToTopTrigger = UUID()
        }
    }

    // MARK: - 모달 시트 제어 헬퍼 메서드

    // 나의 맛집 상세 모달 열기
    func openMyRestaurantDetail(for restaurant: Restaurant) {
        selectedMyRestaurant = restaurant
    }

    // 모든 열려있는 모달 시트 닫기
    func dismissAllSheets() {
        selectedMyRestaurant = nil
    }
}
