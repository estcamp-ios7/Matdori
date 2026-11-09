//
//  RestaurantModel.swift
//  project2
//
//  맛집 데이터 모델 및 열거형 정의
//

import Foundation
import CoreLocation

// MARK: - 음식 카테고리 열거형
enum FoodCategory: String, CaseIterable, Identifiable {
    case all = "전체"
    case korean = "한식"
    case chinese = "중식"
    case japanese = "일식"
    case dessert = "디저트"

    var id: String { rawValue }
}

// MARK: - 메뉴 항목 모델
struct MenuItem: Identifiable {
    let id = UUID()
    let name: String       // 메뉴명
    let price: String      // 가격
    let isSignature: Bool  // 대표 메뉴 여부
}

// MARK: - 커뮤니티 방문자 리뷰 모델
struct CommunityReview: Identifiable {
    let id = UUID()
    var authorName: String   // 작성자 닉네임
    var authorAvatar: String // 작성자 아바타 아이콘
    var rating: Double       // 평점
    var visitDate: String    // 방문 시기
    var content: String      // 리뷰 본문
}

// MARK: - 식당 메인 데이터 모델
struct Restaurant: Identifiable {
    let id = UUID()
    var name: String                         // 식당 이름
    var category: FoodCategory               // 음식 카테고리
    var distanceMeters: Int                  // 현재 위치로부터의 거리 (단위: m)
    var baseRating: Double                   // 기본 별점 (포스트잇 요구사항)
    var address: String                      // 도로명 주소 (포스트잇 요구사항)
    var openCloseTime: String                // 오픈 및 마감시간 (포스트잇 요구사항)
    var phoneNumber: String                  // 전화번호 (포스트잇 요구사항)
    var parkingInfo: String                  // 주차 안내
    var coordinate: CLLocationCoordinate2D   // 지도 상 좌표
    var menus: [MenuItem]                    // 메뉴 및 가격 목록 (포스트잇 요구사항)
    var reviews: [CommunityReview]           // 실제 방문자 리뷰 목록

    // MARK: 사용자 개인화 상태
    var isSaved: Bool = false                // '나의 맛집' 저장 여부
    var myRating: Int? = nil                 // 내가 매긴 별점 (포스트잇 요구사항: 1~5점)
    var myNote: String = ""                  // 개인 메모

    // MARK: 포맷팅된 거리 문자열 (예: 100m, 1.2km)
    var distanceText: String {
        if distanceMeters < 1000 {
            return "\(distanceMeters)m"
        } else {
            let km = Double(distanceMeters) / 1000.0
            return String(format: "%.1fkm", km)
        }
    }
}
