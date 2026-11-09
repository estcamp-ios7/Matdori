//
//  RestaurantViewModel.swift
//  project2
//
//  맛집 데이터 관리 및 비즈니스 로직을 담당하는 뷰모델
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

    // MARK: 나의 맛집 리스트 필터링 카테고리 (검정 포스트잇 요구사항)
    var myListCategory: FoodCategory = .all

    // MARK: 피드 전라도 광주 자치구 필터링 (전체, 동구, 서구, 남구, 북구, 광산구)
    var selectedFeedDistrict: GwangjuDistrict = .all

    // MARK: 주변 맛집 지역/음식/식당 통합 검색어
    var searchQuery: String = ""

    // MARK: 주변 맛집 정렬 옵션 (기본값: 거리순)
    var sortOption: NearbySortOption = .distance

    // MARK: 초기 더미 데이터 리스트 (전라도 광주 5대 구별 특색 맛집 구성)
    var restaurants: [Restaurant] = [
        // 1. 북구 - 용봉 숯불갈비
        Restaurant(
            name: "용봉 숯불갈비",
            category: .korean,
            district: .buk,
            distanceMeters: 100,
            baseRating: 4.8,
            address: "광주 북구 용봉로 77",
            openCloseTime: "11:30 - 22:00 (라스트오더 21:00)",
            phoneNumber: "062-511-1234",
            parkingInfo: "매장 전용 주차장 완비 (2시간 무료)",
            coordinate: CLLocationCoordinate2D(latitude: 35.1765, longitude: 126.9080),
            menus: [
                MenuItem(name: "돼지 숯불갈비 (250g)", price: "16,000원", isSignature: true),
                MenuItem(name: "한우 생갈비 (200g)", price: "32,000원", isSignature: false),
                MenuItem(name: "후식 비빔냉면", price: "6,000원", isSignature: false)
            ],
            reviews: [
                CommunityReview(
                    authorName: "고기러버99",
                    authorAvatar: "person.crop.circle.fill",
                    rating: 5.0,
                    visitDate: "어제",
                    content: "ㄹㅈㄷ맛도리에요오 특히 콰삭킹 같이 주시는 하바네로? 소스랑 같이 먹울때 넘 맛있습니다!"
                )
            ],
            isSaved: false,
            myRating: nil
        ),
        // 2. 북구 - 진미 반점
        Restaurant(
            name: "진미 반점",
            category: .chinese,
            district: .buk,
            distanceMeters: 350,
            baseRating: 4.3,
            address: "광주 북구 설죽로 202",
            openCloseTime: "11:00 - 21:00 (매주 월요일 휴무)",
            phoneNumber: "062-522-5678",
            parkingInfo: "골목 주차 또는 공영주차장 이용",
            coordinate: CLLocationCoordinate2D(latitude: 35.1780, longitude: 126.9110),
            menus: [
                MenuItem(name: "해물 짬뽕", price: "9,000원", isSignature: true),
                MenuItem(name: "찹쌀 탕수육 (소)", price: "18,000원", isSignature: true),
                MenuItem(name: "간짜장", price: "8,000원", isSignature: false)
            ],
            reviews: [
                CommunityReview(
                    authorName: "미식탐험가",
                    authorAvatar: "person.circle",
                    rating: 4.0,
                    visitDate: "3일 전",
                    content: "국물이 진하고 불맛이 살아있어요. 탕수육 튀김옷도 바삭합니다."
                )
            ],
            isSaved: false,
            myRating: nil
        ),
        // 3. 북구 - 하루 스시앤롤
        Restaurant(
            name: "하루 스시앤롤",
            category: .japanese,
            district: .buk,
            distanceMeters: 500,
            baseRating: 4.6,
            address: "광주 북구 비엔날레로 88",
            openCloseTime: "12:00 - 22:00 (브레이크타임 15:00-17:00)",
            phoneNumber: "062-515-9012",
            parkingInfo: "건물 지하주차장 1시간 지원",
            coordinate: CLLocationCoordinate2D(latitude: 35.1795, longitude: 126.9050),
            menus: [
                MenuItem(name: "특선 모듬초밥 (12p)", price: "21,000원", isSignature: true),
                MenuItem(name: "생연어 롤", price: "14,000원", isSignature: false),
                MenuItem(name: "나가사키 우동", price: "11,000원", isSignature: false)
            ],
            reviews: [
                CommunityReview(
                    authorName: "초밥장인",
                    authorAvatar: "person.crop.circle.badge.checkmark",
                    rating: 5.0,
                    visitDate: "지난주",
                    content: "횟감이 정말 신선하고 두툼해요. 가성비 최고입니다."
                )
            ],
            isSaved: false,
            myRating: nil
        ),
        // 4. 북구 - 전통 가마솥 국밥
        Restaurant(
            name: "전통 가마솥 국밥",
            category: .korean,
            district: .buk,
            distanceMeters: 650,
            baseRating: 4.9,
            address: "광주 북구 서암대로 105",
            openCloseTime: "24시간 영업 (연중무휴)",
            phoneNumber: "062-512-7788",
            parkingInfo: "인근 유료주차장 이용 지원",
            coordinate: CLLocationCoordinate2D(latitude: 35.1730, longitude: 126.9130),
            menus: [
                MenuItem(name: "모듬 머리국밥", price: "9,000원", isSignature: true),
                MenuItem(name: "암뽕순대 (한접시)", price: "15,000원", isSignature: true),
                MenuItem(name: "수육 백반", price: "12,000원", isSignature: false)
            ],
            reviews: [
                CommunityReview(
                    authorName: "국밥부장관",
                    authorAvatar: "star.circle",
                    rating: 5.0,
                    visitDate: "어제",
                    content: "국물이 잡내 없이 진국입니다. 김치도 예술이에요."
                )
            ],
            isSaved: false,
            myRating: nil
        ),
        // 5. 동구 - 동명 파스타 키친
        Restaurant(
            name: "동명 파스타 키친",
            category: .westen,
            district: .dong,
            distanceMeters: 3500,
            baseRating: 4.7,
            address: "광주 동구 동명로 14",
            openCloseTime: "11:30 - 21:30 (월요일 휴무)",
            phoneNumber: "062-223-4567",
            parkingInfo: "동명동 공영주차장 1시간 지원",
            coordinate: CLLocationCoordinate2D(latitude: 35.1500, longitude: 126.9240),
            menus: [
                MenuItem(name: "트러플 풍기 크림 파스타", price: "17,000원", isSignature: true),
                MenuItem(name: "수제 비프 라자냐", price: "19,000원", isSignature: true),
                MenuItem(name: "부라타 치즈 샐러드", price: "14,000원", isSignature: false)
            ],
            reviews: [
                CommunityReview(
                    authorName: "동명동주민",
                    authorAvatar: "fork.knife",
                    rating: 5.0,
                    visitDate: "어제",
                    content: "트러플 크림 파스타 풍미가 대박입니다. 동명동 데이트 코스로 강추해요!"
                )
            ],
            isSaved: false,
            myRating: nil
        ),
        // 6. 서구 - 상무 명품한우
        Restaurant(
            name: "상무 명품한우",
            category: .korean,
            district: .seo,
            distanceMeters: 4800,
            baseRating: 4.8,
            address: "광주 서구 상무연하로 28",
            openCloseTime: "11:00 - 22:00",
            phoneNumber: "062-385-9988",
            parkingInfo: "전용 지하주차장 및 발렛 가능",
            coordinate: CLLocationCoordinate2D(latitude: 35.1525, longitude: 126.8520),
            menus: [
                MenuItem(name: "한우 살치살 (150g)", price: "45,000원", isSignature: true),
                MenuItem(name: "한우 꽃등심 (150g)", price: "39,000원", isSignature: true),
                MenuItem(name: "한우 육회비빔밥", price: "13,000원", isSignature: false)
            ],
            reviews: [
                CommunityReview(
                    authorName: "상무직장인",
                    authorAvatar: "star.fill",
                    rating: 5.0,
                    visitDate: "2일 전",
                    content: "회식으로 방문했는데 살치살 마블링이 환상적입니다. 룸도 넓고 쾌적해요."
                )
            ],
            isSaved: false,
            myRating: nil
        ),
        // 7. 남구 - 양림 펭귄당 베이커리
        Restaurant(
            name: "양림 펭귄당 베이커리",
            category: .dessert,
            district: .nam,
            distanceMeters: 5200,
            baseRating: 4.6,
            address: "광주 남구 백서로 84",
            openCloseTime: "10:00 - 21:00",
            phoneNumber: "062-671-2024",
            parkingInfo: "양림역사문화마을 공영주차장 이용",
            coordinate: CLLocationCoordinate2D(latitude: 35.1380, longitude: 126.9150),
            menus: [
                MenuItem(name: "버터 풍미 소금빵", price: "3,500원", isSignature: true),
                MenuItem(name: "무화과 깜빠뉴", price: "6,800원", isSignature: true),
                MenuItem(name: "핸드드립 필터커피", price: "5,500원", isSignature: false)
            ],
            reviews: [
                CommunityReview(
                    authorName: "빵지순례자",
                    authorAvatar: "cup.and.saucer.fill",
                    rating: 4.5,
                    visitDate: "3일 전",
                    content: "소금빵이랑 무화과 깜빠뉴가 너무 담백하고 고소해요. 양림동 산책할 때 필수 코스!"
                )
            ],
            isSaved: false,
            myRating: nil
        ),
        // 8. 광산구 - 송정 원조 떡갈비
        Restaurant(
            name: "송정 원조 떡갈비",
            category: .korean,
            district: .gwangsan,
            distanceMeters: 9800,
            baseRating: 4.9,
            address: "광주 광산구 송정로 29",
            openCloseTime: "09:00 - 22:00",
            phoneNumber: "062-944-1432",
            parkingInfo: "송정 떡갈비골목 전용 주차장 무료",
            coordinate: CLLocationCoordinate2D(latitude: 35.1370, longitude: 126.7930),
            menus: [
                MenuItem(name: "전통 떡갈비 (2대)", price: "16,000원", isSignature: true),
                MenuItem(name: "한우 떡갈비 (2대)", price: "24,000원", isSignature: true),
                MenuItem(name: "육회", price: "30,000원", isSignature: false)
            ],
            reviews: [
                CommunityReview(
                    authorName: "광주토박이",
                    authorAvatar: "flame.fill",
                    rating: 5.0,
                    visitDate: "지난주",
                    content: "달짝지근한 떡갈비와 함께 나오는 맑은 뼈국물이 진짜 일품입니다. 광주 대표 맛집!"
                )
            ],
            isSaved: false,
            myRating: nil
        )
    ]

    // MARK: - 필터링 연산 프로퍼티

    // 주변 맛집 목록 (카테고리, 지역/음식 검색어, 거리순/평점순 정렬 통합 적용)
    var filteredNearbyRestaurants: [Restaurant] {
        var list = restaurants

        // 1. 카테고리 필터
        if selectedCategory != .all {
            list = list.filter { $0.category == selectedCategory }
        }

        // 2. 통합 검색 필터 (식당명, 자치구, 도로명 주소, 카테고리, 음식/메뉴명)
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

    // 나의 맛집 목록 필터링 (저장된 식당 및 카테고리 적용)
    func myRestaurants(category: FoodCategory) -> [Restaurant] {
        restaurants.filter { restaurant in
            restaurant.isSaved && (category == .all || restaurant.category == category)
        }
    }

    // 피드 목록 필터링 (선택된 광주 자치구 적용 - 전라도 광주 한정)
    var filteredFeedRestaurants: [Restaurant] {
        if selectedFeedDistrict == .all {
            return restaurants
        }
        return restaurants.filter { $0.district == selectedFeedDistrict }
    }

    // MARK: - 비즈니스 로직 메서드

    // MARK: 맛집 저장 (신규 저장 시 true, 이미 저장된 경우 false 반환하여 삭제 방지)
    func saveRestaurant(id: UUID) -> Bool {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            if restaurants[index].isSaved {
                // 이미 저장되어 있는 경우 삭제하지 않고 false 반환
                return false
            } else {
                // 신규 저장 처리
                restaurants[index].isSaved = true
                return true
            }
        }
        return false
    }

    // 맛집 저장 상태 토글 (기존 호환 유지)
    func toggleSave(id: UUID) {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            restaurants[index].isSaved.toggle()
        }
    }

    // 나의 맛집에서 삭제 (스와이프 삭제 시 호출)
    func removeFromSaved(id: UUID) {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            restaurants[index].isSaved = false
            restaurants[index].myRating = nil
            restaurants[index].myNote = ""
        }
    }

    // 내가 준 별점 업데이트
    func updateMyRating(id: UUID, rating: Int?) {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            restaurants[index].myRating = rating
        }
    }

    // 나만의 메모 업데이트
    func updateMyNote(id: UUID, note: String) {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            restaurants[index].myNote = note
        }
    }

    // MARK: 피드 당겨서 새로고침 (네트워크 딜레이 시뮬레이션 및 데이터 셔플)
    func refreshFeed() async {
        try? await Task.sleep(nanoseconds: 700_000_000)
        restaurants.shuffle()
    }
}

#Preview("뷰모델 상태 프리뷰") {
    let vm = RestaurantViewModel()
    List {
        Section("상태 요약") {
            Text("현재 위치: \(vm.currentLocation)")
            Text("주변 카테고리: \(vm.selectedCategory.rawValue)")
            Text("피드 선택 구: \(vm.selectedFeedDistrict.rawValue)")
            Text("나의 맛집 카테고리: \(vm.myListCategory.rawValue)")
            Text("전체 식당 수: \(vm.restaurants.count)개")
            Text("저장된 나의 맛집 수: \(vm.myRestaurants(category: .all).count)개")
        }

        Section("식당 목록") {
            ForEach(vm.restaurants) { r in
                HStack {
                    Text("[\(r.district.rawValue)] \(r.name)")
                    Spacer()
                    Text(r.category.rawValue)
                        .foregroundStyle(.secondary)
                    if r.isSaved {
                        Text("저장됨")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
    }
}
