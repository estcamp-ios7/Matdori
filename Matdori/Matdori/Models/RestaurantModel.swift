//
//  RestaurantModel.swift
//  project2
//
//  식당, 메뉴, 리뷰 메인 데이터 모델
//

import Foundation
import CoreLocation

// MARK: - 메뉴 항목 모델
struct MenuItem: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String       // 메뉴명
    let price: String      // 가격
    let isSignature: Bool  // 대표 메뉴 여부

    enum CodingKeys: String, CodingKey {
        case name, price, isSignature
    }
}

// MARK: - 커뮤니티 방문자 리뷰 모델
struct CommunityReview: Identifiable, Codable {
    var id: UUID = UUID()
    var authorName: String       // 작성자 닉네임
    var authorAvatar: String     // 작성자 아바타 아이콘
    var rating: Double           // 평점 (1.0 ~ 5.0)
    var visitDate: String        // 방문 시기
    var content: String          // 리뷰 본문
    var photoName: String? = nil // 리뷰 첨부 사진 (옵셔널)
    var orderCount: Int = 3      // 최근 주문/방문 횟수
    var totalReviewCount: Int = 12 // 작성한 총 리뷰 수
    var userAvgRating: Double = 4.9 // 작성자 평균 별점

    enum CodingKeys: String, CodingKey {
        case authorName, authorAvatar, rating, visitDate, content, photoName, orderCount, totalReviewCount, userAvgRating
    }
}

// MARK: - 식당 메인 데이터 모델
struct Restaurant: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String                         // 식당 이름
    var category: FoodCategory               // 음식 카테고리
    var district: GwangjuDistrict = .yongbong // 광주 주요 상권 (기본값: 용봉동)
    var distanceMeters: Int                  // 현재 위치로부터의 거리 (단위: m)
    var baseRating: Double                   // 기본 별점
    var address: String                      // 도로명 주소
    var openCloseTime: String                // 오픈 및 마감시간
    var phoneNumber: String                  // 전화번호
    var parkingInfo: String                  // 주차 안내
    var coordinate: CLLocationCoordinate2D   // 지도 상 좌표
    var menus: [MenuItem]                    // 메뉴 및 가격 목록
    var reviews: [CommunityReview]           // 실제 방문자 리뷰 목록

    // MARK: 사용자 개인화 상태
    var isSaved: Bool = false                // '나의 맛집' 저장 여부
    var myRating: Int? = nil                 // 내가 매긴 별점 (1~5점)
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

    enum CodingKeys: String, CodingKey {
        case name, category, district, distanceMeters, baseRating, address, openCloseTime, phoneNumber, parkingInfo, latitude, longitude, menus, reviews
    }

    init(
        id: UUID = UUID(),
        name: String,
        category: FoodCategory,
        district: GwangjuDistrict = .yongbong,
        distanceMeters: Int,
        baseRating: Double,
        address: String,
        openCloseTime: String,
        phoneNumber: String,
        parkingInfo: String,
        coordinate: CLLocationCoordinate2D,
        menus: [MenuItem],
        reviews: [CommunityReview],
        isSaved: Bool = false,
        myRating: Int? = nil,
        myNote: String = ""
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.district = district
        self.distanceMeters = distanceMeters
        self.baseRating = baseRating
        self.address = address
        self.openCloseTime = openCloseTime
        self.phoneNumber = phoneNumber
        self.parkingInfo = parkingInfo
        self.coordinate = coordinate
        self.menus = menus
        self.reviews = reviews
        self.isSaved = isSaved
        self.myRating = myRating
        self.myNote = myNote
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.category = try container.decode(FoodCategory.self, forKey: .category)
        self.district = try container.decode(GwangjuDistrict.self, forKey: .district)
        self.distanceMeters = try container.decode(Int.self, forKey: .distanceMeters)
        self.baseRating = try container.decode(Double.self, forKey: .baseRating)
        self.address = try container.decode(String.self, forKey: .address)
        self.openCloseTime = try container.decode(String.self, forKey: .openCloseTime)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.parkingInfo = try container.decode(String.self, forKey: .parkingInfo)

        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

        self.menus = try container.decode([MenuItem].self, forKey: .menus)
        self.reviews = try container.decode([CommunityReview].self, forKey: .reviews)
        self.isSaved = false
        self.myRating = nil
        self.myNote = ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(district, forKey: .district)
        try container.encode(distanceMeters, forKey: .distanceMeters)
        try container.encode(baseRating, forKey: .baseRating)
        try container.encode(address, forKey: .address)
        try container.encode(openCloseTime, forKey: .openCloseTime)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(parkingInfo, forKey: .parkingInfo)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(menus, forKey: .menus)
        try container.encode(reviews, forKey: .reviews)
    }
}
