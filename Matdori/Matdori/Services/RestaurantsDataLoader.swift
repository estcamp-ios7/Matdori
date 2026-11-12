//
//  RestaurantsDataLoader.swift
//  project2
//
//  번들 리소스 및 파일 시스템에서 145곳 맛집 데이터를 디코딩하고
//  앱 초기 실행용 샘플 기록(리뷰 추천 수, 마이페이지 저장 데이터)을 시딩하는 전담 서비스 로더
//

import Foundation
import CoreLocation

// MARK: - 식당 데이터 파일 로더 및 샘플 시더 서비스
struct RestaurantsDataLoader {

    // MARK: 기본 식당 데이터 로드 및 초기 시딩 데이터 통합 반환
    static func loadInitialData() -> [Restaurant] {
        var list = loadRawRestaurants()
        seedReviewHelpfulCounts(into: &list)
        seedMyPageSampleRecords(into: &list)
        return list
    }

    // MARK: 원본 식당 데이터 파일 디코딩 (Bundle 또는 파일 시스템 경로)
    static func loadRawRestaurants() -> [Restaurant] {
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
            "/Users/jangho/Documents/GitHub/Matdori/Matdori/Matdori/RestaurantsData/RestaurantsData.json",
            "/Users/jangho/Documents/GitHub/Matdori/Matdori/Matdori/RestaurantsData/RestaurantsData.txt",
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

    // MARK: - [내부 헬퍼] 리뷰 도움 수 가상 시딩
    private static func seedReviewHelpfulCounts(into list: inout [Restaurant]) {
        for restaurantIndex in list.indices {
            for reviewIndex in list[restaurantIndex].reviews.indices {
                if list[restaurantIndex].reviews[reviewIndex].helpfulCount == 0 {
                    list[restaurantIndex].reviews[reviewIndex].helpfulCount = max(3, 18 - restaurantIndex * 2 - reviewIndex * 3)
                }
            }
        }
    }

    // MARK: - [내부 헬퍼] 마이페이지 레퍼런스 시연용 초기 저장 샘플 주입
    private static func seedMyPageSampleRecords(into list: inout [Restaurant]) {
        guard list.count >= 6 else { return }

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
}
