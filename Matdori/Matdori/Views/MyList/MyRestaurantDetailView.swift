//
//  MyRestaurantDetailView.swift
//  project2
//
//  나의 맛집 상세 페이지 (Apple HIG 터치 타깃 및 Dynamic Type 규격화)
//  (단일 트랜잭션 일괄 커밋 파이프라인 탑재 및 뒤로가기 취소 확인 Alert 지원)
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

    // MARK: 대표 사진 전체 화면 표시 상태
    @State private var isShowingPhotoViewer = false

    // MARK: 변경사항 취소 확인 Alert 표시 상태
    @State private var showDiscardAlert = false

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
                LazyVStack(alignment: .leading, spacing: 16) {
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
                        onRatingChange: { currentMyRating = $0 },
                        onNoteChange: { currentMyNote = $0 }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .scrollIndicators(.hidden)
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .navigationTitle("나의 맛집 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // MARK: 상단 좌측 뒤로가기 버튼 (Label 및 뒤로가기 Alert 연결)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDiscardAlert = true
                    } label: {
                        Label("뒤로", systemImage: "chevron.left")
                            .labelStyle(.titleAndIcon)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                }

                // MARK: 상단 우측 완료 버튼 (Label 및 일괄 커밋 파이프라인 연결)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
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
                            .foregroundStyle(Color.accentColor)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                }
            }
            // MARK: 뒤로가기 시 변경사항 취소 확인 Alert
            .alert("변경사항을 취소하시겠습니까?", isPresented: $showDiscardAlert) {
                Button("계속 작성", role: .cancel) { }
                Button("나가기", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("저장하지 않은 별점 및 메모 변경사항이 사라집니다.")
            }
        }
        .fullScreenCover(isPresented: $isShowingPhotoViewer) {
            if let uiImage = UIImage(named: restaurant.representativePhotoName) {
                RestaurantPhotoViewer(image: uiImage)
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
                .background(Color.accentColor.opacity(colorScheme == .dark ? 0.25 : 0.15))
                .foregroundStyle(Color.accentColor)
                .clipShape(Capsule())
        }
    }

    // MARK: - [헬퍼 서브뷰] 기본 별점 뷰 (RatingStarRow 재사용 컴포넌트 적용)
    private var baseRatingView: some View {
        HStack(spacing: 6) {
            RatingStarRow(rating: restaurant.baseRating, font: .caption)

            Text(String(format: "%.1f", restaurant.baseRating))
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(Color.accentColor)
            Text("(방문자 평가 평균)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - [헬퍼 서브뷰] 상단 대표 사진 영역
    private var topPhotoHeaderView: some View {
        Button {
            isShowingPhotoViewer = true
        } label: {
            GeometryReader { proxy in
                ZStack(alignment: .bottomLeading) {
                    if let uiImage = UIImage(named: restaurant.representativePhotoName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                    } else {
                        Color(uiColor: .tertiarySystemGroupedBackground)
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
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .aspectRatio(16.0 / 9.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("대표 사진 크게 보기")
    }
}

// MARK: - 대표 사진 전체 화면 뷰
private struct RestaurantPhotoViewer: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
                .ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 12)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.black.opacity(0.55), in: Circle()
                )
            }
            .accessibilityLabel("사진 닫기")
            .padding(.top, 16)
            .padding(.trailing, 16)
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
