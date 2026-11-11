//
//  RestaurantTypes.swift
//  project2
//
//  음식 카테고리, 광주광역시 상권/자치구, 정렬 옵션, 마이페이지 탭 및 방문 상태 열거형 정의
//

import Foundation
import CoreLocation

// MARK: - 음식 카테고리 열거형
enum FoodCategory: String, CaseIterable, Identifiable, Codable, Sendable {
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

    // MARK: 카테고리별 기본 대표 에셋 이미지명 (그리드 표출용)
    var defaultPhotoName: String {
        switch self {
        case .korean, .all: return "korean_food_1"
        case .chinese: return "chinese_food_1"
        case .japanese: return "japanese_food_1"
        case .westen: return "etc_food_1"
        case .dessert: return "dessert_food_1"
        case .etc: return "etc_food_2"
        }
    }
}

// MARK: - 광주광역시 주요 상권 및 지역 구분 열거형 (전라도 광주 한정)
enum GwangjuDistrict: String, CaseIterable, Identifiable, Codable, Sendable {
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
enum NearbySortOption: String, CaseIterable, Identifiable, Sendable {
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

// MARK: - 나의 맛집 방문 기록 상태 열거형 (가고 싶은 곳 vs 다녀온 곳)
enum MyVisitStatus: String, CaseIterable, Identifiable, Codable, Sendable {
    case wantToGo = "가고 싶은 곳" // 찜만 해둔 상태
    case visited = "다녀온 곳"     // 실제 방문 완료 상태

    var id: String { rawValue }
}

// MARK: - 마이페이지 나의 맛집 기록 탭 열거형 (리뷰, 다녀온 곳, 가고 싶은 곳)
enum MyRecordTab: String, CaseIterable, Identifiable, Sendable {
    case review = "리뷰"
    case visited = "다녀온 곳"
    case wantToGo = "가고 싶은 곳"

    var id: String { rawValue }
}

// MARK: - 마이페이지 뷰 모드 열거형 (3열 사진 그리드 vs 리스트)
enum MyListViewMode: String, CaseIterable, Identifiable, Sendable {
    case grid = "그리드"
    case list = "리스트"

    var id: String { rawValue }
}
