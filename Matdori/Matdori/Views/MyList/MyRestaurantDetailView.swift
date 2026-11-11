//
//  MyRestaurantDetailView.swift
//  project2
//
//  나의 맛집 상세 페이지 (Apple HIG 터치 타깃 및 Dynamic Type 규격화)
//  (단일 트랜잭션 일괄 커밋 파이프라인 탑재)
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

    // MARK: 방문 상태 버퍼 (가고 싶은 곳 vs 다녀온 곳)
    @State private var currentVisitStatus: MyVisitStatus

    // MARK: 내가 준 별점 상태 (1~5점 또는 nil)
    @State private var currentMyRating: Int?

    // MARK: 나만의 메모 텍스트 상태
    @State private var currentMyNote: String = ""

    // MARK: 초기화 구문: 뷰모델의 최신 값으로 로컬 상태 동기화
    init(viewModel: RestaurantViewModel, restaurant: Restaurant) {
        self.viewModel = viewModel
        self.restaurant = restaurant
        let currentItem = viewModel.restaurants.first(where: { $0.id == restaurant.id }) ?? restaurant
        _currentVisitStatus = State(initialValue: currentItem.visitStatus)
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

                    // MARK: 3. 상단 대표 음식 사진 영역
                    topPhotoHeaderView
                        .padding(.horizontal, 16)

                    // MARK: 4. 나만의 맛집 기록 서브뷰 (방문상태, 별점 및 메모)
                    MyRestaurantRecordSection(
                        restaurantId: restaurant.id,
                        currentVisitStatus: $currentVisitStatus,
                        currentMyRating: $currentMyRating,
                        currentMyNote: $currentMyNote,
                        onRatingChange: { newRating in
                            // 실시간 임시 반영
                            currentMyRating = newRating
                        },
                        onNoteChange: { newNote in
                            // 실시간 텍스트 동기화
                            currentMyNote = newNote
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

                // 상단 우측 완료 버튼 (단일 트랜잭션 일괄 커밋 파이프라인)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // MARK: [파이프라인] 뷰모델 일괄 커밋 실행
                        viewModel.commitMyRestaurantRecord(
                            id: restaurant.id,
                            visitStatus: currentVisitStatus,
                            rating: currentMyRating,
                            note: currentMyNote
                        )
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

    // MARK: - [헬퍼 서브뷰] 상단 대표 사진 영역
    private var topPhotoHeaderView: some View {
        ZStack(alignment: .bottomLeading) {
            if let uiImage = UIImage(named: restaurant.representativePhotoName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                    .frame(height: 180)
            }

            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.6)],
                startPoint: .center,
                endPoint: .bottom
            )

            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                Text(restaurant.address)
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(.white)
            .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
