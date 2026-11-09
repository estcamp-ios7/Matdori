//
//  MyRestaurantListView.swift
//  project2
//
//  나의 맛집 리스트 (카테고리 필터링, 내가 준 별점 동적 노출, 스와이프 삭제, 다크모드 대응)
//

import SwiftUI

// MARK: - 나의 맛집 리스트 화면
struct MyRestaurantListView: View {
    // MARK: 다크모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 뷰모델 바인딩
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 식당 탭 핸들러
    var onSelectRestaurant: (Restaurant) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // MARK: 상단 헤더 타이틀 및 저장 개수
            let items = viewModel.myRestaurants(category: viewModel.myListCategory)

            HStack {
                Text("나의 맛집 리스트")
                    .font(.system(size: 20, weight: .bold))

                Text("(\(items.count))")
                    .font(.system(size: 16, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 56)
            .padding(.bottom, 12)

            // MARK: 카테고리 필터링 (검정 포스트잇: "별점 대신에 한식, 중식, 카테고리를 차라리 필터링을 넣어하자.")
            CategoryFilterBar(selectedCategory: $viewModel.myListCategory)
                .padding(.bottom, 8)

            // MARK: 맛집 카드 리스트 목록
            if items.isEmpty {
                // 비어있는 상태 안내 뷰
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("저장된 맛집이 없습니다.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("주변 맛집이나 피드에서 마음에 드는 곳을 저장해보세요.")
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 60)
            } else {
                List {
                    ForEach(items) { item in
                        MyRestaurantCard(
                            restaurant: item,
                            onTap: { onSelectRestaurant(item) },
                            onRatingChange: { newRating in
                                viewModel.updateMyRating(id: item.id, rating: newRating)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        // 검정 포스트잇 반영: "스와이프로 삭제 기능"
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.removeFromSaved(id: item.id)
                                }
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .padding(.bottom, 60)
            }
        }
//        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .background(Color(uiColor: .secondarySystemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - 나의 맛집 단일 카드 뷰
struct MyRestaurantCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let restaurant: Restaurant
    var onTap: () -> Void
    var onRatingChange: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 상단 행: 이름, 카테고리 태그
            HStack {
                Text(restaurant.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)

                Text(restaurant.category.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.12))
                    .foregroundStyle(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer()
            }

            // 검정 포스트잇 반영: "위치가 보이기 설정 (현재 별점대신 위치로)"
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Text(restaurant.address)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Text(restaurant.distanceText)
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(Color.orange)
            }

            // 요구사항 6: 사용자가 내가 준 별점을 정하면 노출 (nil이 아닐 때만 렌더링)
            if let rating = restaurant.myRating {
                Divider().padding(.vertical, 2)
                HStack {
                    Text("내가 준 별점:")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)

                    // 1~5점 별점 인터랙티브 버튼
                    HStack(spacing: 3) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                onRatingChange(star)
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.system(size: 14))
                                    .foregroundStyle(star <= rating ? Color.orange : Color.gray.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer()

                    Text("\(rating)/5")
                        .font(.system(size: 12, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(Color.orange)
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.04), radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview("나의 맛집 리스트 화면 - 라이트") {
    MyRestaurantListView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
    .preferredColorScheme(.light)
}

#Preview("나의 맛집 리스트 화면 - 다크") {
    MyRestaurantListView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
    .preferredColorScheme(.dark)
}
