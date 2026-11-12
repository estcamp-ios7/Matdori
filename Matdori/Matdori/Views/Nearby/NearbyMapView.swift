//
//  NearbyMapView.swift
//  project2
//
//  내 주변 식당 지도 탐색, 카테고리 필터링 및 리스트 연동 화면 (Apple HIG 규격화)
//

import SwiftUI
import MapKit

// MARK: - [화면 컴포넌트] 주변 맛집 지도 및 리스트 화면 (Apple HIG 준수)
struct NearbyMapView: View {
    // MARK: 맛집 비즈니스 로직, 검색어 및 정렬 옵션 뷰모델
    @Bindable var viewModel: RestaurantViewModel

    // MARK: MapKit 지도 카메라 포지션 및 포커스 제어 상태 모델
    @State private var mapState = NearbyMapViewState()

    // MARK: 지도 영역 접기/펼치기 토글 상태 플래그
    @State private var isMapExpanded = true

    // MARK: 선택된 식당 ID (NavigationPath 푸시 트리거)
    @State private var selectedRestaurantID: UUID?

    // MARK: 내비게이션 스택 경로 상태
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // MARK: 1. 상단 내비게이션 검색바 (지역 선택 및 텍스트 검색)
                NearbySearchBar(viewModel: viewModel)

                // MARK: 2. 음식 카테고리 수평 스크롤 칩 필터 바
                CategoryFilterBar(selectedCategory: $viewModel.selectedCategory)
                    .padding(.bottom, 8)

                // MARK: 3. 접기/펼치기 가능한 지도 뷰 영역
                if isMapExpanded {
                    mapView
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // MARK: 4. 식당 총 개수 표시 및 접기/펼치기/정렬 헤더
                listHeader

                // MARK: 5. 필터링된 식당 리스트 또는 비어있음 안내 뷰
                if viewModel.filteredNearbyRestaurants.isEmpty {
                    emptyStateNoticeView
                } else {
                    List {
                        ForEach(viewModel.filteredNearbyRestaurants) { item in
                            NearbyRestaurantRow(restaurant: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // 행 터치 시 식당 상세 페이지로 네비게이션 이동 트리거
                                    selectedRestaurantID = item.id
                                }
                                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                                .listRowSeparator(.visible, edges: .bottom)
                        }
                    }
                    .listStyle(.plain)
                    .safeAreaPadding(.bottom, 72) // 하단 플로팅 탭바 여백 확보
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground).ignoresSafeArea())
            .navigationTitle("주변 맛집")
            .navigationBarTitleDisplayMode(.inline)
            // MARK: UUID 목적지 기반 식당 상세 화면 푸시
            .navigationDestination(for: UUID.self) { restaurantID in
                if let restaurant = viewModel.restaurants.first(where: { $0.id == restaurantID }) {
                    RestaurantDetailView(viewModel: viewModel, restaurant: restaurant)
                }
            }
            // 선택된 식당 변경 감지 시 네비게이션 패스에 추가
            .onChange(of: selectedRestaurantID) { _, newID in
                guard let newID else { return }
                selectedRestaurantID = nil
                navigationPath.append(newID)
            }
        }
    }

    // MARK: - [서브뷰] MapKit 인터랙티브 지도 뷰
    private var mapView: some View {
        Map(position: $mapState.cameraPosition, interactionModes: [.pan, .zoom]) {
            // 현재 화면에 표시할 주변 식당 마커 핀 순회
            ForEach(viewModel.mapDisplayRestaurants) { item in
                Annotation("", coordinate: item.coordinate) {
                    Button {
                        selectedRestaurantID = item.id
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
        .padding(.bottom, 12)
        // 사용자 위치 변경 시 지도 중심 자동 포커스 동기화
        .onChange(of: viewModel.currentLocation) { _, newLoc in
            mapState.focus(on: newLoc)
        }
    }

    // MARK: - [서브뷰] 리스트 헤더 (개수 카운트, 지도 토글, 정렬 메뉴)
    private var listHeader: some View {
        HStack {
            // 검색된 맛집 총 개수 표출
            Text("맛집 \(viewModel.filteredNearbyRestaurants.count)개")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)

            Spacer()

            // 지도 접기 / 펼치기 토글 버튼
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isMapExpanded.toggle()
                }
            } label: {
                Label(
                    isMapExpanded ? "지도 접기" : "지도 펼치기",
                    systemImage: isMapExpanded ? "map.fill" : "map"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)

            // 정렬 기준 선택 팝업 메뉴
            sortMenu
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    // MARK: - [헬퍼 함수] 카테고리별 원형 지도 핀 마커 렌더링
    private func mapPinMarker(for category: FoodCategory) -> some View {
        ZStack {
            // 외곽 흰색 원형 배경 및 그림자
            Circle()
                .fill(.white)
                .frame(width: 30, height: 30)
                .shadow(color: .black.opacity(0.22), radius: 3, x: 0, y: 2)

            // 내부 액센트 컬러 원형
            Circle()
                .fill(Color.accentColor)
                .frame(width: 25, height: 25)

            // 카테고리 SF Symbol 아이콘
            Image(systemName: category.iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - [서브뷰] 정렬 옵션 메뉴 (가까운순, 평점순, 리뷰순 등)
    private var sortMenu: some View {
        Menu {
            ForEach(NearbySortOption.allCases) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    Label(option.rawValue, systemImage: option.iconName)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 36, height: 36)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(Circle())
        }
    }

    // MARK: - [서브뷰] 검색 결과 없음 안내 뷰
    private var emptyStateNoticeView: some View {
        VStack(spacing: 12) {
            Spacer()
            // 돋보기 아이콘
            Image(systemName: "magnifyingglass")
                .font(.system(size: 38))
                .foregroundStyle(Color.secondary.opacity(0.5))
            // 주 안내 문구
            Text("조건에 맞는 맛집이 없습니다.")
                .font(.headline)
                .foregroundStyle(.secondary)
            // 보조 권유 문구
            Text("다른 검색어나 카테고리를 선택해 보세요.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .safeAreaPadding(.bottom, 72)
    }
}

// MARK: - 프리뷰
#Preview("주변 맛집 지도 - 라이트") {
    NearbyMapView(viewModel: RestaurantViewModel())
        .preferredColorScheme(.light)
}

#Preview("주변 맛집 지도 - 다크") {
    NearbyMapView(viewModel: RestaurantViewModel())
        .preferredColorScheme(.dark)
}
