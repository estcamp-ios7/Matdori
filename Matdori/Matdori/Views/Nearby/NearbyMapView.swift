import SwiftUI
import MapKit

struct NearbyMapView: View {
    @Bindable var viewModel: RestaurantViewModel
    @State private var mapState = NearbyMapViewState()
    @State private var isMapExpanded = true
    @State private var selectedRestaurantID: UUID?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                NearbySearchBar(viewModel: viewModel)

                CategoryFilterBar(selectedCategory: $viewModel.selectedCategory)
                    .padding(.bottom, 8)

                if isMapExpanded {
                    mapView
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                listHeader

                if viewModel.filteredNearbyRestaurants.isEmpty {
                    emptyStateNoticeView
                } else {
                    List {
                        ForEach(viewModel.filteredNearbyRestaurants) { item in
                            NearbyRestaurantRow(restaurant: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedRestaurantID = item.id
                                }
                                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                                .listRowSeparator(.visible, edges: .bottom)
                        }
                    }
                    .listStyle(.plain)
                    .safeAreaPadding(.bottom, 72)
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground).ignoresSafeArea())
            .navigationTitle("주변 맛집")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: UUID.self) { restaurantID in
                if let restaurant = viewModel.restaurants.first(where: { $0.id == restaurantID }) {
                    RestaurantDetailView(viewModel: viewModel, restaurant: restaurant)
                }
            }
            .onChange(of: selectedRestaurantID) { _, newID in
                guard let newID else { return }
                selectedRestaurantID = nil
                // NavigationPath를 직접 노출하지 않고 UUID 목적지로 푸시합니다.
                navigationPath.append(newID)
            }
        }
    }

    private var mapView: some View {
        Map(position: $mapState.cameraPosition, interactionModes: [.pan, .zoom]) {
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
        .onChange(of: viewModel.currentLocation) { _, newLoc in
            mapState.focus(on: newLoc)
        }
    }

    private var listHeader: some View {
        HStack {
            Text("맛집 \(viewModel.filteredNearbyRestaurants.count)개")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)

            Spacer()

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
                .foregroundStyle(.orange)
            }
            .buttonStyle(.plain)

            sortMenu
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private func mapPinMarker(for category: FoodCategory) -> some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 30, height: 30)
                .shadow(color: .black.opacity(0.22), radius: 3, x: 0, y: 2)

            Circle()
                .fill(.orange)
                .frame(width: 25, height: 25)

            Image(systemName: category.iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
        }
    }

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
                .foregroundStyle(.orange)
                .frame(width: 36, height: 36)
                .background(Color.orange.opacity(0.12))
                .clipShape(Circle())
        }
    }

    private var emptyStateNoticeView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 38))
                .foregroundStyle(Color.secondary.opacity(0.5))
            Text("조건에 맞는 맛집이 없습니다.")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("다른 검색어나 카테고리를 선택해 보세요.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .safeAreaPadding(.bottom, 72)
    }
}
