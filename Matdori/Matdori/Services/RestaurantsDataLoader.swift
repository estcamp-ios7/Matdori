//
//  RestaurantsDataLoader.swift
//  project2
//
//  번들 리소스 및 파일 시스템에서 145곳 맛집 데이터를 디코딩하는 서비스 로더
//

import Foundation
import CoreLocation

// MARK: - 식당 데이터 파일 로더 서비스
struct RestaurantsDataLoader {
    static func load() -> [Restaurant] {
        // 1. 번들 내 JSON 또는 TXT 리소스 검색
        let possibleExtensions = ["json", "txt"]
        for ext in possibleExtensions {
            if let url = Bundle.main.url(forResource: "RestaurantsData", withExtension: ext),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([Restaurant].self, from: data),
               !decoded.isEmpty {
                return decoded
            }
        }

        // 2. 개발 및 테스트 환경용 절대 경로 폴백
        let fallbackPaths = [
            "/Users/jangho/Documents/GitHub/Matdori/Matdori/Matdori/RestaurantsData.json",
            "/Users/jangho/Documents/GitHub/Matdori/Matdori/Matdori/RestaurantsData.txt"
        ]
        for path in fallbackPaths {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
               let decoded = try? JSONDecoder().decode([Restaurant].self, from: data),
               !decoded.isEmpty {
                return decoded
            }
        }

        // 3. 파일 로드 실패 시의 안전 폴백 데이터
        return [
            Restaurant(
                name: "용봉 숯불갈비",
                category: .korean,
                district: .yongbong,
                distanceMeters: 100,
                baseRating: 4.8,
                address: "광주 북구 용봉로 77",
                openCloseTime: "11:30 - 22:00",
                phoneNumber: "062-511-1234",
                parkingInfo: "매장 전용 주차장 완비 (2시간 무료)",
                coordinate: CLLocationCoordinate2D(latitude: 35.1765, longitude: 126.9080),
                menus: [MenuItem(name: "돼지 숯불갈비", price: "16,000원", isSignature: true)],
                reviews: [
                    CommunityReview(
                        authorName: "고기러버99",
                        authorAvatar: "person.crop.circle.fill",
                        rating: 5.0,
                        visitDate: "어제",
                        content: "숯불 향이 살아있고 고기가 부드럽습니다."
                    )
                ]
            )
        ]
    }
}
