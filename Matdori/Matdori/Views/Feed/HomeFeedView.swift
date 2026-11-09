//
//  HomeFeedView.swift
//  project2
//
//  전라도 광주 지역 한정 숨은 맛집 피드 화면
//  - 광주 5대 자치구(동구, 서구, 남구, 북구, 광산구) 필터링 지원
//  - 이웃들의 생생한 솔직 방문 후기 및 음식 사진 썸네일 노출
//  - 다크모드 대응 디자인 및 당겨서 새로고침(.refreshable) 제공
//

import SwiftUI

// MARK: - 홈 피드 메인 화면 뷰
struct HomeFeedView: View {
    // MARK: [환경 변수] 시스템 다크모드/라이트모드 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: [상태 바인딩] 식당 데이터 및 필터 상태를 공유하는 맛집 뷰모델
    @Bindable var viewModel: RestaurantViewModel

    // MARK: [이벤트 핸들러] 피드 카드를 탭했을 때 탐색용 상세페이지를 띄우기 위한 클로저
    var onSelectRestaurant: (Restaurant) -> Void

    // MARK: [네비게이션 제어] 피드 탭 재선택 시 Pop to Root 처리를 위한 NavigationPath 바인딩
    @Binding var navigationPath: NavigationPath

    // MARK: [스크롤 제어] 메인 피드 최상단 스크롤을 위한 트리거 ID
    var scrollToTopTrigger: UUID = UUID()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // MARK: 0. 최상단 스크롤 앵커 포인트
                        Color.clear
                            .frame(height: 0)
                            .id("feedTopAnchor")

                        // MARK: 1. 상단 지역 인디케이터 배지 및 메인 타이틀 영역
                VStack(alignment: .leading, spacing: 8) {
                    // 광주광역시 한정 서비스임을 알리는 상단 배지
                    HStack(spacing: 6) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.orange)

                        Text("광주광역시 한정 피드")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.orange)

                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.12))
                    .clipShape(Capsule())

                    // 메인 헤더 타이틀 및 서비스 안내 문구
                    VStack(alignment: .leading, spacing: 4) {
                        Text("광주 맛집 피드 & 찐리뷰")
                            .font(.system(size: 22, weight: .bold))

                        Text("전라도 광주 이웃들의 솔직한 실시간 방문 후기")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 56)

                // MARK: 2. 광주 5대 자치구 필터 바 (전체, 동구, 서구, 남구, 북구, 광산구)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // 광주 자치구 열거형 전체 항목을 순회하며 칩 버튼 생성
                        ForEach(GwangjuDistrict.allCases) { district in
                            Button {
                                // 자치구 변경 시 부드러운 스프링 애니메이션 적용
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    viewModel.selectedFeedDistrict = district
                                }
                            } label: {
                                Text(district.rawValue)
                                    .font(.system(size: 13, weight: viewModel.selectedFeedDistrict == district ? .bold : .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    // 선택된 칩은 오렌지 배경, 미선택 칩은 시스템 보조 배경 적용
                                    .background(
                                        viewModel.selectedFeedDistrict == district
                                        ? Color.orange
                                        : Color(uiColor: .secondarySystemGroupedBackground)
                                    )
                                    // 텍스트 색상: 선택 시 흰색, 미선택 시 기본 텍스트 색상
                                    .foregroundStyle(
                                        viewModel.selectedFeedDistrict == district
                                        ? Color.white
                                        : Color.primary
                                    )
                                    .clipShape(Capsule())
                                    // 미선택 칩에 은은한 외곽선 부여
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                viewModel.selectedFeedDistrict == district
                                                ? Color.clear
                                                : (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.06)),
                                                lineWidth: 1
                                            )
                                    )
                                    // 선택된 칩에 오렌지 글로우 그림자 효과
                                    .shadow(
                                        color: viewModel.selectedFeedDistrict == district ? Color.orange.opacity(0.3) : Color.clear,
                                        radius: 4,
                                        x: 0,
                                        y: 2
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 2)
                }

                // MARK: 3. 이웃들이 공유한 방문자 리뷰 피드 목록
                VStack(alignment: .leading, spacing: 12) {
                    // 피드 섹션 헤더 (현재 선택된 구 이름 및 식당 개수 표시)
                    HStack {
                        Text("🔥 \(viewModel.selectedFeedDistrict == .all ? "광주 전체" : viewModel.selectedFeedDistrict.rawValue) 이웃 리뷰 피드")
                            .font(.system(size: 16, weight: .bold))

                        Spacer()

                        Text("\(viewModel.filteredFeedRestaurants.count)곳")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)

                    // 현재 선택된 자치구에 등록된 맛집 리뷰가 없는 경우
                    if viewModel.filteredFeedRestaurants.isEmpty {
                        VStack(spacing: 10) {
                            Spacer()

                            Image(systemName: "newspaper")
                                .font(.system(size: 38))
                                .foregroundStyle(.tertiary)

                            Text("아직 \(viewModel.selectedFeedDistrict.rawValue)에 등록된 리뷰가 없습니다.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)

                            Text("다른 자치구를 선택해보세요.")
                                .font(.system(size: 12))
                                .foregroundStyle(.tertiary)

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, minHeight: 180)
                    } else {
                        // 필터링된 식당 목록 순회하며 피드 카드 렌더링 (NavigationPath 연동)
                        ForEach(viewModel.filteredFeedRestaurants) { r in
                            if let firstReview = r.reviews.first {
                                NavigationLink(value: r.id) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        // [피드 카드 상단] 작성자 아바타, 닉네임, 자치구 태그, 식당 이름 및 방문 시기
                                        HStack {
                                            // 작성자 아바타 아이콘
                                            Image(systemName: firstReview.authorAvatar)
                                                .font(.system(size: 20))
                                                .foregroundStyle(.orange)

                                            VStack(alignment: .leading, spacing: 1) {
                                                // 닉네임과 자치구 뱃지
                                                HStack(spacing: 6) {
                                                    Text(firstReview.authorName)
                                                        .font(.system(size: 13, weight: .bold))

                                                    // 광주 자치구 뱃지 (예: 광주 동구, 광주 북구)
                                                    Text("광주 \(r.district.rawValue)")
                                                        .font(.system(size: 10, weight: .semibold))
                                                        .padding(.horizontal, 5)
                                                        .padding(.vertical, 2)
                                                        .background(Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.12))
                                                        .foregroundStyle(Color.orange)
                                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                                }

                                                // 식당 이름 및 방문 시기 서브텍스트
                                                Text("\(r.name) • \(firstReview.visitDate)")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(.secondary)
                                            }

                                            Spacer()
                                        }

                                        // [피드 카드 본문] 음식 사진 썸네일 + 5점 별점 + 2줄 본문 말줄임
                                        HStack(alignment: .top, spacing: 10) {
                                            // 좌측: 음식 사진 정사각형 썸네일 (58x58)
                                            reviewThumbnailView(review: firstReview, category: r.category)

                                            // 우측: 별점 및 리뷰 내용
                                            VStack(alignment: .leading, spacing: 5) {
                                                // 노란색 5점 별점 (리뷰 작성자가 매긴 점수에 따라 채워짐)
                                                HStack(spacing: 2) {
                                                    ForEach(1...5, id: \.self) { star in
                                                        Image(systemName: star <= Int(firstReview.rating) ? "star.fill" : "star")
                                                            .font(.system(size: 11))
                                                            .foregroundStyle(Color.yellow)
                                                    }
                                                }

                                                // 리뷰 본문 텍스트 (최대 2줄 제한 및 넘침 시 말줄임 처리)
                                                Text(firstReview.content)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(2)
                                                    .truncationMode(.tail)
                                                    .lineSpacing(3)
                                            }

                                            Spacer(minLength: 0)
                                        }
                                    }
                                    .padding(14)
                                    // 카드 배경 스타일 및 코너 라운딩
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    // 다크모드/라이트모드에 적합한 외곽선 적용
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04), lineWidth: 1)
                                    )
                                    // 카드 입체감을 위한 은은한 그림자
                                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.04), radius: 5, x: 0, y: 2)
                                    .padding(.horizontal, 16)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                // 하단 플로팅 탭바와 겹치지 않도록 충분한 여백 확보
                .padding(.bottom, 60)
            }
            // 전체 화면 배경색 설정 (시스템 그룹 배경)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            // MARK: 4. 당겨서 새로고침 (.refreshable 비동기 로직 연동)
            .refreshable {
                await viewModel.refreshFeed()
            }
            // 피드 탭 재선택 이벤트 발생 시 피드 메인 최상단으로 부드럽게 스크롤 이동
            .onChange(of: scrollToTopTrigger) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    scrollProxy.scrollTo("feedTopAnchor", anchor: .top)
                }
            }
        }
    }
    // MARK: 5. 피드 상세 게시글 네비게이션 목적지 (NavigationPath 연동)
    .navigationDestination(for: UUID.self) { restaurantID in
        if let r = viewModel.restaurants.first(where: { $0.id == restaurantID }),
           let firstReview = r.reviews.first {
            FeedPostDetailView(
                restaurant: r,
                review: firstReview,
                onSelectRestaurant: onSelectRestaurant
            )
        }
    }
    }
}

    // MARK: - [헬퍼 함수] 리뷰 음식 사진 썸네일 뷰 빌더
    @ViewBuilder
    private func reviewThumbnailView(review: CommunityReview, category: FoodCategory) -> some View {
        // 리뷰에 첨부된 실제 사진 에셋이 존재하는 경우
        if let photoName = review.photoName, let uiImage = UIImage(named: photoName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            // 사진이 없을 때 사용하는 따뜻한 음식 톤의 사진 플레이스홀더 (그라데이션 및 음식 카테고리 심볼)
            ZStack {
                // 먹음직스러운 웜톤 그라데이션 배경
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.68, blue: 0.30),
                        Color(red: 0.85, green: 0.46, blue: 0.16)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // 음식 카테고리별 SF Symbol 아이콘
                Image(systemName: categoryIconName(for: category))
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.92))
                    .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
            }
            .frame(width: 58, height: 58)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
            )
        }
    }

    // MARK: - [헬퍼 함수] 음식 카테고리에 맞는 대표 SF Symbol 심볼명 반환
    private func categoryIconName(for category: FoodCategory) -> String {
        category.iconName
    }
}

// MARK: - 프리뷰 (라이트 모드)
#Preview("홈 피드 화면 - 라이트") {
    @Previewable @State var path = NavigationPath()
    HomeFeedView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in },
        navigationPath: $path
    )
    .preferredColorScheme(.light)
}

// MARK: - 프리뷰 (다크 모드)
#Preview("홈 피드 화면 - 다크") {
    @Previewable @State var path = NavigationPath()
    HomeFeedView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in },
        navigationPath: $path
    )
    .preferredColorScheme(.dark)
}
