//
//  RestaurantDetailView.swift
//  project2
//
//  식당 상세 정보 페이지 (Apple HIG 터치 타깃 및 Dynamic Type 규격화)
//  (서브뷰 RestaurantInfoSection, RestaurantMenuSection 분리 적용)
//

import SwiftUI

// MARK: - 식당 상세페이지 메인 뷰 (Apple HIG 준수)
struct RestaurantDetailView: View {
    // MARK: 시스템 다크모드 감지 및 화면 닫기 환경 변수
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    // MARK: 뷰모델 바인딩
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 대상 식당 정보
    var restaurant: Restaurant

    // MARK: 맛집 신규 추가 완료 알림창 상태
    @State private var showAddedAlert = false

    // MARK: 이미 저장된 가게 알림창 상태
    @State private var showAlreadySavedAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: 1. 상단 지도 및 대표 사진 와이어프레임
                    topMapWireframeView
                        .padding(.horizontal, 16)

                    // MARK: 2. 기본 정보 헤더 (Semantic Title2 & Headline)
                    basicInfoHeader
                        .padding(.horizontal, 16)

                    Divider().padding(.horizontal, 16)

                    // MARK: 3. 상세 정보 섹션 서브뷰 (주소, 영업시간, 전화번호, 주차)
                    RestaurantInfoSection(restaurant: restaurant)
                        .padding(.horizontal, 16)

                    // MARK: 4. 메뉴 및 가격 섹션 서브뷰
                    RestaurantMenuSection(restaurant: restaurant)
                        .padding(.horizontal, 16)

                    // MARK: 5. 실제 방문자 리뷰 섹션
                    reviewsSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .navigationTitle("식당 상세페이지")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 상단 좌측 닫기 버튼 (HIG 44x44pt 보장)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }

                // 상단 우측 '나의 맛집'에 저장(+) 버튼 (HIG 44x44pt 보장)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let isNewlySaved = viewModel.saveRestaurant(id: restaurant.id)
                        if isNewlySaved {
                            showAddedAlert = true
                        } else {
                            showAlreadySavedAlert = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.orange)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
            }
            // 저장 완료 알림창
            .alert("나의 맛집에 추가되었습니다!", isPresented: $showAddedAlert) {
                Button("확인", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("'나의 맛집'에 저장되었습니다.")
            }
            // 이미 저장된 식당 중복 알림창
            .alert("이미 저장된 가게입니다", isPresented: $showAlreadySavedAlert) {
                Button("확인", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("'나의 맛집' 리스트에 이미 등록되어 있습니다.")
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 상단 지도 와이어프레임
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

    // MARK: - [헬퍼 서브뷰] 기본 정보 헤더 (Apple HIG Semantic Typography)
    private var basicInfoHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
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

            // 기본 평점 (방문자 평가 평균)
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
    }

    // MARK: - [헬퍼 서브뷰] 방문자 리뷰 섹션 (Apple HIG 가독성 규격)
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("실제 방문자 리뷰 (\(restaurant.reviews.count))")
                .font(.headline)

            // 실제 리뷰 목록 순회 렌더링
            ForEach(restaurant.reviews) { rev in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: rev.authorAvatar)
                            .font(.subheadline)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.orange)

                        Text(rev.authorName)
                            .font(.subheadline.weight(.semibold))

                        Spacer()

                        Text(rev.visitDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text(String(format: "%.1f", rev.rating))
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(Color.orange)
                    }

                    Text(rev.content)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

// MARK: - 프리뷰
#Preview("식당 상세페이지 - 라이트") {
    RestaurantDetailView(
        viewModel: RestaurantViewModel(),
        restaurant: RestaurantViewModel().restaurants[0]
    )
    .preferredColorScheme(.light)
}

#Preview("식당 상세페이지 - 다크") {
    RestaurantDetailView(
        viewModel: RestaurantViewModel(),
        restaurant: RestaurantViewModel().restaurants[0]
    )
    .preferredColorScheme(.dark)
}
