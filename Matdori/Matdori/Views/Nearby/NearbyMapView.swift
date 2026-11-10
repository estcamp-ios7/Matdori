//
//  NearbyMapView.swift
//  project2
//
//  Apple MapKit 기반 주변 맛집 지도 탐색 및 통합 검색/정렬 화면
//  (성능 최적화: 선별된 Top 40 마커 표출 및 서브뷰 분리)
//

import SwiftUI
import MapKit

// MARK: - [메인 화면] 주변 맛집 탐색 뷰
struct NearbyMapView: View {
    // MARK: 식당 목록 데이터 및 필터링 상태를 공유하는 뷰모델
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 식당 상세 모달 시트를 띄우는 이벤트 클로저
    var onSelectRestaurant: (Restaurant) -> Void

    // MARK: 지도 카메라 전용 뷰 상태 모델
    @State private var mapState = NearbyMapViewState()

    var body: some View {
        VStack(spacing: 0) {
            // MARK: 1 & 2. 위치 드롭다운 및 스마트 검색창 서브뷰
            NearbySearchBar(viewModel: viewModel)

            // MARK: 3. 카테고리 필터 바 (전체, 한식, 중식, 일식, 디저트 등)
            CategoryFilterBar(selectedCategory: $viewModel.selectedCategory)
                .padding(.bottom, 8)

            // MARK: 4. MapKit 기반 실제 지도 뷰 (선별된 Top 40 마커 표출로 GPU 렌더링 부하 해소)
            Map(position: $mapState.cameraPosition) {
                ForEach(viewModel.mapDisplayRestaurants) { item in
                    Annotation("", coordinate: item.coordinate) {
                        Button {
                            onSelectRestaurant(item)
                        } label: {
                            mapPinMarker(for: item.category)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .frame(height: 270)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .onChange(of: viewModel.currentLocation) { _, newLoc in
                // 상단 위치 변경 시 카메라 부드러운 패닝
                mapState.focus(on: newLoc)
            }

            // MARK: 5. 맛집 목록 헤더 (검색 결과 수 & 정렬 피커)
            HStack {
                Text("맛집 \(viewModel.filteredNearbyRestaurants.count)개")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)

                Spacer()

                sortMenu
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 2)

            // MARK: 6. 하단 맛집 목록 리스트 (단일 행 서브뷰 적용)
            if viewModel.filteredNearbyRestaurants.isEmpty {
                emptyStateNoticeView
            } else {
                List {
                    ForEach(viewModel.filteredNearbyRestaurants) { item in
                        NearbyRestaurantRow(restaurant: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelectRestaurant(item)
                            }
                            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            .listRowSeparator(.visible, edges: .bottom)
                    }
                }
                .listStyle(.plain)
                .padding(.bottom, 60)
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - [헬퍼 서브뷰] 지도 핀 마커 (원형 흰색 테두리 + 주황 배경 + 카테고리 심볼)
    private func mapPinMarker(for category: FoodCategory) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 30, height: 30)
                .shadow(color: .black.opacity(0.22), radius: 3, x: 0, y: 2)

            Circle()
                .fill(Color.orange)
                .frame(width: 25, height: 25)

            Image(systemName: category.iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - [헬퍼 서브뷰] 정렬 메뉴 드롭다운 (거리순/평점순)
    private var sortMenu: some View {
        Menu {
            ForEach(NearbySortOption.allCases) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if viewModel.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: viewModel.sortOption.iconName)
                    .font(.system(size: 12))

                Text(viewModel.sortOption.rawValue)
                    .font(.system(size: 13, weight: .bold))

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.orange.opacity(0.12))
            .foregroundStyle(Color.orange)
            .clipShape(Capsule())
            .contentShape(Rectangle())
        }
    }

    // MARK: - [헬퍼 서브뷰] 빈 검색 결과 안내 뷰
    private var emptyStateNoticeView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 38))
                .foregroundStyle(Color.secondary.opacity(0.5))

            Text("조건에 맞는 맛집이 없습니다.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            Text("다른 검색어나 카테고리를 선택해 보세요.")
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 60)
    }
}

// MARK: - 프리뷰
#Preview("주변 맛집 지도 - 라이트") {
    NearbyMapView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
    .preferredColorScheme(.light)
}

#Preview("주변 맛집 지도 - 다크") {
    NearbyMapView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
    .preferredColorScheme(.dark)
}
