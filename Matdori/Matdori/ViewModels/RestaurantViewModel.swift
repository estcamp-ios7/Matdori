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

    // MARK: 초기 더미 데이터 리스트 (기본 저장된 맛집 없음: isSaved = false, myRating = nil)
    var restaurants: [Restaurant] = [
        Restaurant(
            name: "용봉 숯불갈비",
            category: .korean,
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
                    content: "숯불 향이 제대로 배어있고 육즙이 가득해요. 부모님 모시고 가기 딱 좋습니다!"
                )
            ],
            isSaved: false,
            myRating: nil
        ),
        Restaurant(
            name: "진미 반점",
            category: .chinese,
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
        Restaurant(
            name: "하루 스시앤롤",
            category: .japanese,
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
        Restaurant(
            name: "카페 몽마르뜨",
            category: .dessert,
            distanceMeters: 220,
            baseRating: 4.1,
            address: "광주 북구 저불로 31",
            openCloseTime: "10:00 - 23:00",
            phoneNumber: "062-529-3344",
            parkingInfo: "매장 앞 2대 주차 가능",
            coordinate: CLLocationCoordinate2D(latitude: 35.1750, longitude: 126.9095),
            menus: [
                MenuItem(name: "바닐라빈 수플레 팬케이크", price: "13,500원", isSignature: true),
                MenuItem(name: "핸드드립 아메리카노", price: "5,000원", isSignature: false),
                MenuItem(name: "얼그레이 크림 라떼", price: "6,500원", isSignature: false)
            ],
            reviews: [
                CommunityReview(
                    authorName: "디저트요정",
                    authorAvatar: "heart.circle",
                    rating: 4.0,
                    visitDate: "2주 전",
                    content: "수플레 팬케이크가 입안에서 녹아내려요. 사진도 잘 나옵니다."
                )
            ],
            isSaved: false,
            myRating: nil
        ),
        Restaurant(
            name: "전통 가마솥 국밥",
            category: .korean,
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
        )
    ]

    // MARK: - 필터링 연산 프로퍼티

    // 주변 맛집 목록 (선택된 카테고리 적용)
    var filteredNearbyRestaurants: [Restaurant] {
        if selectedCategory == .all {
            return restaurants
        }
        return restaurants.filter { $0.category == selectedCategory }
    }

    // 나의 맛집 목록 필터링 (저장된 식당 및 카테고리 적용)
    func myRestaurants(category: FoodCategory) -> [Restaurant] {
        restaurants.filter { restaurant in
            restaurant.isSaved && (category == .all || restaurant.category == category)
        }
    }

    // MARK: - 비즈니스 로직 메서드

    // MARK: 피드 새로고침 비즈니스 로직 (.refreshable 연동)
    func refreshFeed() async {
        // 네트워크 통신 지연 시뮬레이션
        try? await Task.sleep(for: .milliseconds(600))

        // 최신 피드 데이터 갱신 시뮬레이션: 첫 번째 식당의 리뷰를 최신 방문으로 갱신
        if !restaurants.isEmpty, !restaurants[0].reviews.isEmpty {
            restaurants[0].reviews[0].visitDate = "방금 전"
        }
    }

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
        }
    }

    // 내가 준 별점 업데이트
    func updateMyRating(id: UUID, rating: Int) {
        if let index = restaurants.firstIndex(where: { $0.id == id }) {
            restaurants[index].myRating = rating
        }
    }
}

#Preview("뷰모델 상태 프리뷰") {
    let vm = RestaurantViewModel()
    List {
        Section("상태 요약") {
            Text("현재 위치: \(vm.currentLocation)")
            Text("주변 카테고리: \(vm.selectedCategory.rawValue)")
            Text("나의 맛집 카테고리: \(vm.myListCategory.rawValue)")
            Text("전체 식당 수: \(vm.restaurants.count)개")
            Text("저장된 나의 맛집 수: \(vm.myRestaurants(category: .all).count)개")
        }

        Section("식당 목록") {
            ForEach(vm.restaurants) { r in
                HStack {
                    Text(r.name)
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
