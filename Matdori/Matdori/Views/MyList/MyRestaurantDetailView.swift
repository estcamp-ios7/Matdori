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

    // MARK: 대표 사진 전체 화면 표시 상태
    @State private var isShowingPhotoViewer = false

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
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerView
                        .padding(.horizontal, 16)

                    baseRatingView
                        .padding(.horizontal, 16)

                    topPhotoHeaderView
                        .padding(.horizontal, 16)

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
                .padding(.top, 88)
            }
            .scrollIndicators(.hidden)
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())

            detailNavigationHeader
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .background(Color(uiColor: .systemBackground).ignoresSafeArea(edges: .top))
        }
        .fullScreenCover(isPresented: $isShowingPhotoViewer) {
            if let uiImage = UIImage(named: restaurant.representativePhotoName) {
                RestaurantPhotoViewer(image: uiImage)
            }
        }
    }

    private var detailNavigationHeader: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 66, height: 66)
                    .background(Color(uiColor: .systemBackground), in: Circle())
                    .overlay(Circle().stroke(Color.primary.opacity(0.12), lineWidth: 1))
            }
            .accessibilityLabel("뒤로")

            Spacer()

            Text("나의 맛집 상세")
                .font(.title3.weight(.bold))

            Spacer()

            Button {
                viewModel.commitMyRestaurantRecord(
                    id: restaurant.id,
                    visitStatus: currentVisitStatus,
                    rating: currentMyRating,
                    note: currentMyNote
                )
                dismiss()
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 66, height: 66)
                    .background(Color(uiColor: .systemBackground), in: Circle())
                    .overlay(Circle().stroke(Color.primary.opacity(0.12), lineWidth: 1))
            }
            .accessibilityLabel("완료")
        }
        .frame(maxWidth: .infinity)
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
                    .background(.black.opacity(0.55), in: Circle())
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
