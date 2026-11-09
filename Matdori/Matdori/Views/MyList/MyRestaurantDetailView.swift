//
//  MyRestaurantDetailView.swift
//  project2
//
//  나의 맛집 상세 페이지 (나만의 별점 평가 및 메모 작성 전용 화면)
//

import SwiftUI

// MARK: - 나의 맛집 상세페이지 화면
struct MyRestaurantDetailView: View {
    // MARK: 다크모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    // MARK: 뷰모델 바인딩
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 대상 식당 정보
    var restaurant: Restaurant

    // MARK: 내가 준 별점 상태 (선택되지 않은 경우 nil)
    @State private var currentMyRating: Int?

    // MARK: 나만의 메모 상태
    @State private var currentMyNote: String = ""

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
                    // MARK: 1. 상단 지도 및 대표 사진 영역 (와이어프레임 형태)
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                            .frame(height: 180)

                        VStack(spacing: 8) {
                            Image(systemName: "map")
                                .font(.system(size: 36))
                                .foregroundStyle(Color.gray.opacity(0.5))
                            Text("지도 영역: \(restaurant.name)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: 2. 기본 정보 헤더 (식당 이름, 카테고리, 기본 별점)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(restaurant.name)
                                .font(.system(size: 24, weight: .bold))

                            Spacer()

                            Text(restaurant.category.rawValue)
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.15))
                                .foregroundStyle(Color.orange)
                                .clipShape(Capsule())
                        }

                        // 기본 별점 (방문자 평가 평균)
                        HStack(spacing: 6) {
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { idx in
                                    Image(systemName: idx <= Int(restaurant.baseRating) ? "star.fill" : (Double(idx) - 0.5 <= restaurant.baseRating ? "star.leadinghalf.filled" : "star"))
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.orange)
                                }
                            }
                            Text(String(format: "%.1f", restaurant.baseRating))
                                .font(.system(size: 15, weight: .bold))
                                .monospacedDigit()
                                .foregroundStyle(Color.orange)
                            Text("(방문자 평가 평균)")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: 3. 나만의 맛집 기록 섹션 (별점 & 메모)
                    VStack(alignment: .leading, spacing: 14) {
                        // 헤더
                        HStack {
                            Image(systemName: "bookmark.fill")
                                .foregroundStyle(Color.orange)
                            Text("나만의 맛집 기록")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                            if let rating = currentMyRating {
                                Text("\(rating) / 5점")
                                    .font(.system(size: 13, weight: .bold))
                                    .monospacedDigit()
                                    .foregroundStyle(Color.orange)
                            } else {
                                Text("별점을 선택해주세요")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // 나만의 별점 부여 (1~5점)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("나의 별점")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)

                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { star in
                                    Button {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                                            if currentMyRating == star {
                                                currentMyRating = nil
                                                viewModel.updateMyRating(id: restaurant.id, rating: nil)
                                            } else {
                                                currentMyRating = star
                                                viewModel.updateMyRating(id: restaurant.id, rating: star)
                                            }
                                        }
                                    } label: {
                                        Image(systemName: (currentMyRating != nil && star <= (currentMyRating ?? 0)) ? "star.fill" : "star")
                                            .font(.system(size: 28))
                                            .foregroundStyle((currentMyRating != nil && star <= (currentMyRating ?? 0)) ? Color.orange : Color.gray.opacity(0.35))
                                    }
                                    .buttonStyle(.plain)
                                }

                                if currentMyRating != nil {
                                    Button {
                                        withAnimation {
                                            currentMyRating = nil
                                            viewModel.updateMyRating(id: restaurant.id, rating: nil)
                                        }
                                    } label: {
                                        Text("초기화")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.gray.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.leading, 4)
                                }
                            }
                            .padding(.vertical, 2)
                        }

                        Divider()

                        // 나만의 메모 작성
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.orange)
                                Text("나만의 메모")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                if !currentMyNote.isEmpty {
                                    Text("\(currentMyNote.count)자")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.tertiary)
                                }
                            }

                            TextField("나만의 맛집 팁, 추천 메뉴, 재방문 의사 등을 자유롭게 메모해보세요.", text: $currentMyNote, axis: .vertical)
                                .lineLimit(14...14)
                                .font(.system(size: 14))
                                .padding(12)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08), lineWidth: 1)
                                )
                                .onChange(of: currentMyNote) { _, newValue in
                                    viewModel.updateMyNote(id: restaurant.id, note: newValue)
                                }
                        }
                    }
                    .padding(16)
                    .background(Color.orange.opacity(colorScheme == .dark ? 0.15 : 0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .navigationTitle("나의 맛집 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }

                // 완료 버튼
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.updateMyNote(id: restaurant.id, note: currentMyNote)
                        dismiss()
                    } label: {
                        Label("완료", systemImage: "checkmark")
                            .labelStyle(.titleAndIcon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.orange)
                    }
                }
            }
        }
    }
}

#Preview("나의 맛집 상세 - 라이트") {
    let vm = RestaurantViewModel()
    MyRestaurantDetailView(
        viewModel: vm,
        restaurant: vm.restaurants[0]
    )
    .preferredColorScheme(.light)
}

#Preview("나의 맛집 상세 - 다크") {
    let vm = RestaurantViewModel()
    MyRestaurantDetailView(
        viewModel: vm,
        restaurant: vm.restaurants[0]
    )
    .preferredColorScheme(.dark)
}
