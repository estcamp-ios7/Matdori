//
//  RestaurantViewModel.swift
//  project2
//
//  맛집 데이터 관리 및 비즈니스 로직을 담당하는 뷰모델
//  (성능 최적화: 검색어 고속 패스, 지도 전용 마커 분리, 데이터 로더 서비스 분리)
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

    // MARK: 초기 맛집 리스트 (데이터 로더 서비스를 통해 로드)
    var restaurants: [Restaurant] = []

    init() {
        var list = RestaurantsDataLoader.load()

        // 진솔한 리뷰 피드에서 도움을 많이 받은 대표 리뷰가 먼저 보이도록 샘플 반응 수를 준비합니다.
        for restaurantIndex in list.indices {
            for reviewIndex in list[restaurantIndex].reviews.indices {
                if list[restaurantIndex].reviews[reviewIndex].helpfulCount == 0 {
                    list[restaurantIndex].reviews[reviewIndex].helpfulCount = max(3, 18 - restaurantIndex * 2 - reviewIndex * 3)
                }
            }
        }

        // MARK: 마이페이지 레퍼런스 화면처럼 풍성한 데이터를 위해 초기 6개 식당에 샘플 기록 주입
        if list.count >= 6 {
            list[0].isSaved = true
            list[0].visitStatus = .visited
            list[0].myRating = 5
            list[0].myNote = "국물이 진하고 불향이 예술입니다. 재방문 의사 100%!"

            list[1].isSaved = true
            list[1].visitStatus = .visited
            list[1].myRating = 4
            list[1].myNote = "보리굴비와 게장 밑반찬 구성이 전라도의 깊은 손맛을 보여줌."

            list[2].isSaved = true
            list[2].visitStatus = .wantToGo
            list[2].myRating = 5
            list[2].myNote = "파스타 소스가 일품이라고 추천받아서 꼭 가볼 예정."

            list[3].isSaved = true
            list[3].visitStatus = .visited
            list[3].myRating = 4
            list[3].myNote = "매콤달콤한 양념 떡볶이와 튀김 조합이 최고."

            list[4].isSaved = true
            list[4].visitStatus = .visited
            list[4].myRating = 5
            list[4].myNote = "신선한 스시와 정갈한 플레이팅으로 대접받는 느낌."

            list[5].isSaved = true
            list[5].visitStatus = .wantToGo
            list[5].myNote = "딸기 케이크와 핸드드립 커피 비주얼이 너무 예뻐 찜해둠."
        }

        self.restaurants = list
    }

    // MARK: - 필터링 연산 프로퍼티

    // 주변 맛집 목록 (카테고리, 검색어 고속 패스, 정렬 통합 적용)
    var filteredNearbyRestaurants: [Restaurant] {
        var list = restaurants

        // 1. 카테고리 필터
        if selectedCategory != .all {
            list = list.filter { $0.category == selectedCategory }
        }

        // 2. 통합 검색 필터 (고속 패스: 검색어가 비어있을 때는 O(N) 문자열 매칭 건너뜀)
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            list = list.filter { r in
                let matchName = r.name.lowercased().contains(query)
                let matchDistrict = r.district.rawValue.lowercased().contains(query)
                let matchAddress = r.address.lowercased().contains(query)
                let matchCategory = r.category.rawValue.lowercased().contains(query)
                let matchMenu = r.menus.contains { $0.name.lowercased().contains(query) }
                return matchName || matchDistrict || matchAddress || matchCategory || matchMenu
            }
        }

        // 3. 정렬 옵션 적용 (거리순 오름차순, 평점순 내림차순)
        switch sortOption {
        case .distance:
            list.sort { $0.distanceMeters < $1.distanceMeters }
        case .rating:
            list.sort { $0.baseRating > $1.baseRating }
        }

        return list
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

    // MARK: 마이페이지 선택된 탭 및 카테고리별 필터링 식당 목록
    var myTabFilteredRestaurants: [Restaurant] {
        restaurants.filter { r in
            guard r.isSaved else { return false }

            // 1. 카테고리 필터
            if myListCategory != .all && r.category != myListCategory {
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

    // 피드 목록 필터링 (선택된 광주 자치구 + 피드 검색어 다중 필드 매칭)
    var filteredFeedRestaurants: [Restaurant] {
        var list = restaurants

        // 1. 광주 자치구 필터 적용
        if selectedFeedDistrict != .all {
            list = list.filter { $0.district == selectedFeedDistrict }
        }

        // 2. 피드 검색어 필터 (고속 패스: 비어있을 때 즉시 반환)
        let query = feedSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            list = list.filter { r in
                let matchName = r.name.lowercased().contains(query)
                let matchDistrict = r.district.rawValue.lowercased().contains(query)
                let matchCategory = r.category.rawValue.lowercased().contains(query)
                let matchMenu = r.menus.contains { $0.name.lowercased().contains(query) }
                let matchReview = r.reviews.contains {
                    $0.content.lowercased().contains(query) || $0.authorName.lowercased().contains(query)
                }
                return matchName || matchDistrict || matchCategory || matchMenu || matchReview
            }
        }

        return list
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
