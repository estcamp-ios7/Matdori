//
//  MyRestaurantListView.swift
//  project2
//
//  나의 맛집 리스트 (카테고리 필터링, 내가 준 별점 동적 노출, 스와이프 삭제, 다크모드 대응)
//  (서브뷰 MyRestaurantCard 분리 적용)
//

import SwiftUI

// MARK: - 나의 맛집 리스트 화면
struct MyRestaurantListView: View {
    // MARK: 시스템 다크모드 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 저장된 맛집 데이터 및 필터 상태 관리 뷰모델
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 식당 행 선택 시 상세 모달을 띄우는 이벤트 핸들러
    var onSelectRestaurant: (Restaurant) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 현재 선택된 카테고리 기준 저장된 식당 목록 산출
            let items = viewModel.myRestaurants(category: viewModel.myListCategory)

            // MARK: 1. 상단 헤더 타이틀 및 저장 개수 카운트
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

            // MARK: 2. 카테고리 수평 필터링 칩 바
            CategoryFilterBar(selectedCategory: $viewModel.myListCategory)
                .padding(.bottom, 8)

            // MARK: 3. 저장된 맛집 카드 리스트 목록
            if items.isEmpty {
                // 저장된 맛집이 없을 때의 안내 뷰
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
                // 저장된 식당 리스트 렌더링
                List {
                    ForEach(items) { item in
                        // 개별 카드 서브뷰
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
                        // 스와이프로 삭제 인터랙션 지원
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
        .background(Color(uiColor: .secondarySystemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - 프리뷰
#Preview("나의 맛집 리스트 - 라이트") {
    MyRestaurantListView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
    .preferredColorScheme(.light)
}

#Preview("나의 맛집 리스트 - 다크") {
    MyRestaurantListView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
    .preferredColorScheme(.dark)
}
