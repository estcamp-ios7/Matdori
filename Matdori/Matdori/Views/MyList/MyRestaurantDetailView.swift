//
//  MyRestaurantDetailView.swift
//  project2
//
//  나의 맛집 상세 페이지 (Apple HIG 터치 타깃 및 Dynamic Type 규격화)
//  (서브뷰 MyRestaurantRecordSection 분리 및 레거시 코드 정리)
//

import SwiftUI

// MARK: - 나의 맛집 상세페이지 화면 (Apple HIG 준수)
struct MyRestaurantDetailView: View {
    // MARK: 시스템 라이트/다크모드 감지 및 화면 닫기 환경 변수
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    // MARK: 뷰모델 바인딩
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 대상 식당 정보
    var restaurant: Restaurant

    // MARK: 내가 준 별점 상태 (1~5점 또는 nil)
    @State private var currentMyRating: Int?

    // MARK: 나만의 메모 텍스트 상태
    @State private var currentMyNote: String = ""

    // MARK: 초기화 구문: 뷰모델의 최신 값으로 로컬 상태 동기화
    init(viewModel: RestaurantViewModel, restaurant: Restaurant) {
        self.viewModel = viewModel
        self.restaurant = restaurant
        let currentItem = viewModel.restaurants.first(where: { $0.id == restaurant.id }) ?? restaurant
        _currentMyRating = State(initialValue: currentItem.myRating)
        _currentMyNote = State(initialValue: currentItem.myNote)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: 1. 식당 이름 및 카테고리 태그 헤더
                    headerView
                        .padding(.horizontal, 16)

                    // MARK: 2. 기본 별점 (방문자 평가 평균)
                    baseRatingView
                        .padding(.horizontal, 16)

                    // MARK: 3. 상단 지도 및 대표 사진 영역
                    topMapWireframeView
                        .padding(.horizontal, 16)

                    // MARK: 4. 나만의 맛집 기록 서브뷰 (별점 및 메모)
                    MyRestaurantRecordSection(
                        restaurantId: restaurant.id,
                        currentMyRating: $currentMyRating,
                        currentMyNote: $currentMyNote,
                        onRatingChange: { newRating in
                            viewModel.updateMyRating(id: restaurant.id, rating: newRating)
                        },
                        onNoteChange: { newNote in
                            viewModel.updateMyNote(id: restaurant.id, note: newNote)
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .navigationTitle("나의 맛집 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 상단 좌측 닫기 뒤로가기 버튼 (HIG Label titleAndIcon 표준)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("뒤로", systemImage: "chevron.left")
                            .labelStyle(.titleAndIcon)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                }

                // 상단 우측 완료 버튼 (HIG Label titleAndIcon 표준)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("완료", systemImage: "checkmark")
                            .labelStyle(.titleAndIcon)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.orange)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 헤더 뷰 (Semantic Title2 & Subheadline)
    private var headerView: some View {
        HStack {
            Text(restaurant.name)
                .font(.title2.weight(.bold))

            Spacer()

            Text(restaurant.category.rawValue)
                .font(.subheadline.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.15))
                .foregroundStyle(Color.orange)
                .clipShape(Capsule())
        }
    }

    // MARK: - [헬퍼 서브뷰] 기본 별점 뷰 (Semantic Subheadline & Caption)
    private var baseRatingView: some View {
        HStack(spacing: 6) {
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { idx in
                    Image(systemName: idx <= Int(restaurant.baseRating) ? "star.fill" : (Double(idx) - 0.5 <= restaurant.baseRating ? "star.leadinghalf.filled" : "star"))
                        .font(.caption)
                        .foregroundStyle(Color.orange)
                }
            }
            Text(String(format: "%.1f", restaurant.baseRating))
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(Color.orange)
            Text("(방문자 평가 평균)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - [헬퍼 서브뷰] 지도 와이어프레임 뷰
    private var topMapWireframeView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                .frame(height: 180)

            VStack(spacing: 8) {
                Image(systemName: "map")
                    .font(.largeTitle)
                    .foregroundStyle(Color.gray.opacity(0.5))
                Text("지도 영역: \(restaurant.name)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - 프리뷰
#Preview("나의 맛집 상세 - 라이트") {
    MyRestaurantDetailView(
        viewModel: RestaurantViewModel(),
        restaurant: RestaurantViewModel().restaurants[0]
    )
    .preferredColorScheme(.light)
}

#Preview("나의 맛집 상세 - 다크") {
    MyRestaurantDetailView(
        viewModel: RestaurantViewModel(),
        restaurant: RestaurantViewModel().restaurants[0]
    )
    .preferredColorScheme(.dark)
}
