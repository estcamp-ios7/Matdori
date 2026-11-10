//
//  RestaurantTypes.swift
//  project2
//
//  음식 카테고리, 광주광역시 상권/자치구, 정렬 옵션 열거형 정의
//

import Foundation
import CoreLocation

// MARK: - 음식 카테고리 열거형
enum FoodCategory: String, CaseIterable, Identifiable, Codable {
    case all = "전체"
    case korean = "한식"
    case chinese = "중식"
    case japanese = "일식"
    case westen = "양식"
    case dessert = "디저트"
    case etc = "기타"

    var id: String { rawValue }

    // MARK: 카테고리별 대표 SF Symbol 아이콘
    var iconName: String {
        switch self {
        case .korean, .chinese, .japanese, .westen:
            return "fork.knife"
        case .dessert:
            return "cup.and.saucer.fill"
        case .all, .etc:
            return "storefront.fill"
        }
    }
}

// MARK: - 광주광역시 주요 상권 및 지역 구분 열거형 (전라도 광주 한정)
enum GwangjuDistrict: String, CaseIterable, Identifiable, Codable {
    case all = "전체"
    case yongbong = "용봉동"     // 북구
    case dongmyeong = "동명동"   // 동구
    case sangmu = "상무지구"     // 서구
    case suwan = "수완지구"       // 광산구
    case yangrim = "양림동"      // 남구

    var id: String { rawValue }

    // MARK: 상권 중심 위도/경도 좌표
    var coordinate: CLLocationCoordinate2D? {
        switch self {
        case .all:
            return nil
        case .yongbong:
            return CLLocationCoordinate2D(latitude: 35.1765, longitude: 126.9080)
        case .dongmyeong:
            return CLLocationCoordinate2D(latitude: 35.1485, longitude: 126.9240)
        case .sangmu:
            return CLLocationCoordinate2D(latitude: 35.1530, longitude: 126.8510)
        case .suwan:
            return CLLocationCoordinate2D(latitude: 35.1910, longitude: 126.8220)
        case .yangrim:
            return CLLocationCoordinate2D(latitude: 35.1380, longitude: 126.9140)
        }
    }

    // MARK: '전체'를 제외한 실제 선택 가능한 상권 목록
    static var selectableLocations: [GwangjuDistrict] {
        allCases.filter { $0 != .all }
    }
}

// MARK: - 주변 맛집 정렬 옵션 열거형
enum NearbySortOption: String, CaseIterable, Identifiable {
    case distance = "거리순"
    case rating = "평점순"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .distance: return "location.fill"
        case .rating: return "star.fill"
        }
    }
}
