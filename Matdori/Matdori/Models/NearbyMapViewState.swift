//
//  NearbyMapViewState.swift
//  project2
//
//  MapKit 카메라 좌표 및 줌 레벨 상태 캡슐화 모델
//

import SwiftUI
import MapKit
import Observation

// MARK: - 지도 화면 전용 뷰 상태 모델
@Observable
final class NearbyMapViewState {
    // MARK: 기본 카메라 중심 위치 (광주 북구 용봉동 상권 일대)
    var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: GwangjuDistrict.yongbong.coordinate ?? CLLocationCoordinate2D(latitude: 35.1765, longitude: 126.9080),
            span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
        )
    )

    // MARK: 특정 자치구/상권 명칭으로 카메라 부드럽게 패닝 이동
    func focus(on locationName: String) {
        // 일치하는 상권 열거형 및 해당 좌표가 유효한지 확인
        guard let district = GwangjuDistrict.allCases.first(where: { $0.rawValue == locationName }),
              let coord = district.coordinate else { return }

        // 0.45초간 easeInOut 커브 애니메이션으로 카메라 중심 좌표 갱신
        withAnimation(.easeInOut(duration: 0.45)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
                )
            )
        }
    }
}
