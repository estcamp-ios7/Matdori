//
//  NearbyMapView.swift
//  project2
//
//  주변 맛집 지도 및 리스트 탐색 화면
//

import SwiftUI

// MARK: - 주변 맛집 화면
struct NearbyMapView: View {
    // MARK: 뷰모델 바인딩
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 식당 선택 이벤트 핸들러
    var onSelectRestaurant: (Restaurant) -> Void

    // MARK: 변경 가능한 가상 위치 목록
    let sampleLocations = ["용봉동", "동명동", "상무지구", "수완지구", "양림동"]

    var body: some View {
        VStack(spacing: 0) {
            // MARK: 상단 헤더 (현재 위치 탭 시 드롭다운 메뉴로 위치 변경)
            HStack {
                Menu {
                    ForEach(sampleLocations, id: \.self) { loc in
                        Button(loc) {
                            viewModel.currentLocation = loc
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.orange)
                        Text("현재 위치: ")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.secondary)
                        Text(viewModel.currentLocation)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.orange)
                    }
                    .padding(.vertical, 4)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 56)
            .padding(.bottom, 8)

            // MARK: 카테고리 필터 (전체, 한식, 중식, 일식, 디저트)
            CategoryFilterBar(selectedCategory: $viewModel.selectedCategory)
                .padding(.bottom, 8)

            // MARK: 상단 지도 일러스트 뷰 (와이어프레임 핀 배치)
            MapIllustrationView(
                restaurants: viewModel.filteredNearbyRestaurants,
                onSelectPin: { restaurant in
                    onSelectRestaurant(restaurant)
                }
            )
            .frame(height: 190)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // MARK: 하단 맛집 목록 리스트
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
            .listStyle(.automatic)
            .padding(.bottom, 60) // 하단 탭바 여백
        }
//        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .background(Color(uiColor: .secondarySystemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - 지도 그래픽 뷰 컴포넌트
struct MapIllustrationView: View {
    let restaurants: [Restaurant]
    var onSelectPin: (Restaurant) -> Void

    var body: some View {
        ZStack {
            // 지도 배경 색상
            Color(uiColor: .tertiarySystemGroupedBackground)

            // 가상 격자 도로망 그리기
            GeometryReader { geo in
                Path { path in
                    let w = geo.size.width
                    let h = geo.size.height
                    // 가로 도로선
                    path.move(to: CGPoint(x: 0, y: h * 0.35))
                    path.addLine(to: CGPoint(x: w, y: h * 0.35))
                    path.move(to: CGPoint(x: 0, y: h * 0.7))
                    path.addLine(to: CGPoint(x: w, y: h * 0.7))
                    // 세로 도로선
                    path.move(to: CGPoint(x: w * 0.3, y: 0))
                    path.addLine(to: CGPoint(x: w * 0.3, y: h))
                    path.move(to: CGPoint(x: w * 0.7, y: 0))
                    path.addLine(to: CGPoint(x: w * 0.7, y: h))
                }
                .stroke(Color.gray.opacity(0.18), lineWidth: 4)

                // 지도 중앙 접힌 지도 아이콘 (와이어프레임 재현)
                VStack(spacing: 4) {
                    Image(systemName: "map")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.gray.opacity(0.45))
                    Text("용봉로 상권 탐색")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.gray.opacity(0.6))
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)

                // 식당 핀 마커 배치
                ForEach(Array(restaurants.enumerated()), id: \.element.id) { index, item in
                    let pinX = mapPinPositionX(index: index, width: geo.size.width)
                    let pinY = mapPinPositionY(index: index, height: geo.size.height)

                    Button {
                        onSelectPin(item)
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.red)
                                .background(Circle().fill(.white).padding(2))
                                .shadow(radius: 2)

                            Text(item.name)
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.95))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .foregroundStyle(Color.black)
                                .shadow(color: .black.opacity(0.1), radius: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    .position(x: pinX, y: pinY)
                }
            }
        }
    }

    // X좌표 오프셋 계산 함수
    private func mapPinPositionX(index: Int, width: CGFloat) -> CGFloat {
        let offsets: [CGFloat] = [0.2, 0.5, 0.8, 0.32, 0.72]
        return width * offsets[index % offsets.count]
    }

    // Y좌표 오프셋 계산 함수
    private func mapPinPositionY(index: Int, height: CGFloat) -> CGFloat {
        let offsets: [CGFloat] = [0.28, 0.22, 0.30, 0.78, 0.75]
        return height * offsets[index % offsets.count]
    }
}

// MARK: - 주변 맛집 리스트 단일 행 뷰
struct NearbyRestaurantRow: View {
    let restaurant: Restaurant

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    // 식당 이름
                    Text(restaurant.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)

                    // 기본 별점 표시 (와이어프레임: ★ 4.8)
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                        Text(String(format: "%.1f", restaurant.baseRating))
                            .font(.system(size: 12, weight: .semibold))
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                    }

                    // 저장된 식당인 경우 배지 노출
                    if restaurant.isSaved {
                        Text("저장됨")
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }

                // 카테고리 텍스트
                Text(restaurant.category.rawValue)
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
            }

            Spacer()

            // 거리 및 화살표 표시
            HStack(spacing: 4) {
                Text(restaurant.distanceText)
                    .font(.system(size: 13, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.gray.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("주변 맛집 지도 화면") {
    NearbyMapView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
}
