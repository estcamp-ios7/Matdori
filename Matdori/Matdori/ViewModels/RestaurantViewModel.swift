//
//  RestaurantViewModel.swift
//  project2
//
//  맛집 데이터 관리 및 비즈니스 로직을 담당하는 뷰모델
//  (성능 최적화: 단일 패스 필터링 파이프라인, 검색어 정규화 캐싱, 지도 마커 슬라이싱, 서비스 레이어 분리)
//

import SwiftUI
import CoreLocation

// MARK: - 맛집 뷰모델 (Swift 6 Strict Concurrency 준수를 위한 @MainActor 격리)
@MainActor
@Observable
final class RestaurantViewModel {

    // MARK: 사용자 현재 위치 상태
    var currentLocation: String = "용봉동"

    // MARK: 주변 맛집 필터링 카테고리
    var selectedCategory: FoodCategory = .all

    // MARK: 나의 맛집 리스트 필터링 카테고리
    var myListCategory: FoodCategory = .all

    // MARK: 마이페이지 선택된 기록 탭 (리뷰, 다녀온 곳, 가고 싶은 곳)
    var selectedMyRecordTab: MyRecordTab = .review

    // MARK: 마이페이지 뷰 모드 (3열 사진 그리드 vs 리스트)
    var myListViewMode: MyListViewMode = .grid

    // MARK: 피드 전라도 광주 자치구 필터링 (전체, 동구, 서구, 남구, 북구, 광산구)
    var selectedFeedDistrict: GwangjuDistrict = .all

    // MARK: 주변 맛집 지역/음식/식당 통합 검색어
    var searchQuery: String = ""

    // MARK: 피드 화면 전용 검색어 (주변 탭 검색어와 독립 분리)
    var feedSearchQuery: String = ""

    // MARK: 주변 맛집 정렬 옵션 (기본값: 거리순)
    var sortOption: NearbySortOption = .distance

    // MARK: 식당 리스트 (데이터 로더 서비스를 통해 초기 데이터 및 시딩 레코드 로드)
    var restaurants: [Restaurant] = []

    init() {
        self.restaurants = RestaurantsDataLoader.loadInitialData()
    }

    // MARK: - 성능 최적화된 필터링 연산 파이프라인

    // 주변 맛집 목록 (단일 패스 조건 필터링 + 인플레이스 정렬로 불필요한 중간 배열 생성 방지)
    var filteredNearbyRestaurants: [Restaurant] {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let hasQuery = !trimmedQuery.isEmpty
        let hasCategory = (selectedCategory != .all)

        // 단일 패스로 카테고리와 검색어 조건을 일괄 평가하여 탐색 비용 최적화
        var result = restaurants.filter { restaurant in
            if hasCategory && restaurant.category != selectedCategory {
                return false
            }

            guard hasQuery else { return true }

            let matchName = restaurant.name.localizedCaseInsensitiveContains(trimmedQuery)
            let matchDistrict = restaurant.district.rawValue.localizedCaseInsensitiveContains(trimmedQuery)
            let matchAddress = restaurant.address.localizedCaseInsensitiveContains(trimmedQuery)
            let matchCategory = restaurant.category.rawValue.localizedCaseInsensitiveContains(trimmedQuery)
            let matchMenu = restaurant.menus.contains { $0.name.localizedCaseInsensitiveContains(trimmedQuery) }

            return matchName || matchDistrict || matchAddress || matchCategory || matchMenu
        }

        // 정렬 옵션 적용
        switch sortOption {
        case .distance:
            result.sort { $0.distanceMeters < $1.distanceMeters }
        case .rating:
            result.sort { $0.baseRating > $1.baseRating }
        }

        return result
    }

    // MARK: [성능 최적화] 지도 전용 표출 마커 컬렉션 (Top 40곳 슬라이싱으로 MapKit GPU 과부하 방지)
    var mapDisplayRestaurants: [Restaurant] {
        let nearby = filteredNearbyRestaurants
        if nearby.count > 40 {
            return Array(nearby.prefix(40))
        }
        return nearby
    }

    // 나의 맛집 목록 필터링 (저장된 식당 및 카테고리 적용)
    func myRestaurants(category: FoodCategory) -> [Restaurant] {
        restaurants.filter { restaurant in
            restaurant.isSaved && (category == .all || restaurant.category == category)
        }
    }

    // MARK: - 마이페이지 스탯 카운터 (다녀온 곳, 가고 싶은 곳, 리뷰)
    var visitedCount: Int {
        restaurants.filter { $0.isSaved && ($0.visitStatus == .visited || $0.myRating != nil) }.count
    }

    var wantToGoCount: Int {
        restaurants.filter { $0.isSaved && $0.visitStatus == .wantToGo && $0.myRating == nil }.count
    }

    var reviewCount: Int {
        restaurants.filter { $0.isSaved && ($0.myRating != nil || !$0.myNote.isEmpty) }.count
    }

    // MARK: 마이페이지 선택된 탭 및 카테고리별 필터링 식당 목록 (단일 패스 조건 필터링)
    var myTabFilteredRestaurants: [Restaurant] {
        let hasCategory = (myListCategory != .all)

        return restaurants.filter { r in
            guard r.isSaved else { return false }

            // 1. 카테고리 필터
            if hasCategory && r.category != myListCategory {
                return false
            }

            // 2. 마이페이지 탭별 분기
            switch selectedMyRecordTab {
            case .review:
                return r.myRating != nil || !r.myNote.isEmpty
            case .visited:
                return r.visitStatus == .visited || r.myRating != nil
            case .wantToGo:
                return r.visitStatus == .wantToGo && r.myRating == nil
            }
        }
    }

    // 피드 목록 필터링 (단일 패스로 자치구 및 검색어 다중 필드 매칭)
    var filteredFeedRestaurants: [Restaurant] {
        let trimmedQuery = feedSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let hasQuery = !trimmedQuery.isEmpty
        let hasDistrict = (selectedFeedDistrict != .all)

        return restaurants.filter { r in
            // 자치구 필터
            if hasDistrict && r.district != selectedFeedDistrict {
                return false
            }

            // 검색어 고속 패스
            guard hasQuery else { return true }

            let matchName = r.name.localizedCaseInsensitiveContains(trimmedQuery)
            let matchDistrict = r.district.rawValue.localizedCaseInsensitiveContains(trimmedQuery)
            let matchCategory = r.category.rawValue.localizedCaseInsensitiveContains(trimmedQuery)
            let matchMenu = r.menus.contains { $0.name.localizedCaseInsensitiveContains(trimmedQuery) }
            let matchReview = r.reviews.contains {
                $0.content.localizedCaseInsensitiveContains(trimmedQuery) || $0.authorName.localizedCaseInsensitiveContains(trimmedQuery)
            }

            return matchName || matchDistrict || matchCategory || matchMenu || matchReview
        }
    }

    // MARK: - 비즈니스 로직 메서드 & 저장 파이프라인

    // MARK: [파이프라인] MyRestaurantDetailView 단일 트랜잭션 일괄 커밋
    func commitMyRestaurantRecord(id: UUID, visitStatus: MyVisitStatus, rating: Int?, note: String) {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            restaurants[index].isSaved = true
            restaurants[index].visitStatus = visitStatus
            restaurants[index].myRating = rating
            restaurants[index].myNote = note
        }
    }

    // 맛집 저장 (신규 저장 시 true, 이미 저장된 경우 false 반환)
    func saveRestaurant(id: UUID) -> Bool {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            if restaurants[index].isSaved {
                return false
            } else {
                restaurants[index].isSaved = true
                return true
            }
        }
        return false
    }

    // 맛집 저장 상태 토글
    func toggleSave(id: UUID) {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            restaurants[index].isSaved.toggle()
        }
    }

    // 나의 맛집에서 삭제
    func removeFromSaved(id: UUID) {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            restaurants[index].isSaved = false
            restaurants[index].visitStatus = .wantToGo
            restaurants[index].myRating = nil
            restaurants[index].myNote = ""
        }
    }

    // 내가 준 별점 업데이트
    func updateMyRating(id: UUID, rating: Int?) {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            restaurants[index].myRating = rating
            if rating != nil {
                restaurants[index].visitStatus = .visited
            }
        }
    }

    // 나만의 메모 업데이트
    func updateMyNote(id: UUID, note: String) {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            restaurants[index].myNote = note
        }
    }

    // 피드 당겨서 새로고침
    func refreshFeed() async {
        try? await Task.sleep(nanoseconds: 600_000_000)
    }
}
