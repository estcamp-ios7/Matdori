//
//  MyRestaurantListView.swift
//  project2
//
//  마이페이지 나의 맛집 탭 (첨부된 디자인 레퍼런스 1:1 완벽 구현 & Apple HIG 규격화)
//  (프로필, 3대 스탯, 리뷰어 랭킹, 3분할 탭바, 3열 사진 그리드/리스트 뷰 전환 지원)
//

import SwiftUI

// MARK: - 마이페이지 화면 (Apple HIG 준수)
struct MyRestaurantListView: View {
    // MARK: 시스템 다크모드 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 뷰모델 바인딩
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 식당 선택 시 상세 화면 오픈 콜백
    var onSelectRestaurant: (Restaurant) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // MARK: 1. 프로필 & 3대 스탯 & 프로필 편집 버튼
                    profileSection

                    // MARK: 2. 11월의 맛집 탐험가 랭킹 배지 카드
                    reviewerRankBadgeCard

                    // MARK: 3. 나의 맛집 기록 섹션 헤더 & 3분할 탭 바 (리뷰 | 다녀온 곳 | 가고 싶은 곳)
                    recordSectionHeader

                    // MARK: 4. 음식 카테고리 필터 메뉴 & 뷰 모드 전환 버튼
                    filterAndDisplayToolbar

                    // MARK: 5. 3열 사진 그리드 또는 리스트 뷰
                    if viewModel.myTabFilteredRestaurants.isEmpty {
                        emptyStateView
                    } else {
                        if viewModel.myListViewMode == .grid {
                            photoGridView
                        } else {
                            cardListView
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 60)
            }
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .navigationTitle("마이페이지")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 상단 우측 공유 및 설정 아이콘 (HIG 44x44pt 터치 영역)
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        Button {
                            // 공유 액션
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)
                                .frame(minWidth: 44, minHeight: 44)
                                .contentShape(Rectangle())
                        }

                        Button {
                            // 설정 액션
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)
                                .frame(minWidth: 44, minHeight: 44)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
        }
    }

    // MARK: - [헬퍼 서브뷰] 1. 프로필 & 스탯 영역
    private var profileSection: some View {
        VStack(spacing: 16) {
            // 아바타 및 유저 정보
            HStack(spacing: 14) {
                // 곰돌이 캐릭터 아바타
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(red: 0.98, green: 0.82, blue: 0.60))
                        .frame(width: 72, height: 72)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Color(red: 0.88, green: 0.52, blue: 0.28))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("광주먹보")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)

                    Text("광주 맛집 도장 깨는 중 🍜")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Text("한식 · 일식 · 라멘 애호가")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            // 3대 스탯 카운터 (다녀온 곳, 가고 싶은 곳, 팔로워)
            HStack(alignment: .center) {
                statItem(title: "다녀온 곳", count: "\(viewModel.visitedCount)")
                Spacer()
                statItem(title: "가고 싶은 곳", count: "\(viewModel.wantToGoCount)")
                Spacer()
                statItem(title: "팔로워", count: "1,248")
            }
            .padding(.horizontal, 24)

            // 프로필 편집 버튼 (오렌지 풀와이드 버튼)
            Button {
                // 프로필 편집 액션
            } label: {
                Text("프로필 편집")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44) // HIG 44pt 보장
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - [헬퍼 서브뷰] 개별 스탯 컴포넌트
    private func statItem(title: String, count: String) -> some View {
        VStack(spacing: 4) {
            Text(count)
                .font(.headline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 70)
    }

    // MARK: - [헬퍼 서브뷰] 2. 리뷰어 랭킹 배지 카드
    private var reviewerRankBadgeCard: some View {
        HStack(spacing: 12) {
            Text("🏆")
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("11월의 맛집 탐험가")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)

                Text("광주 지역 리뷰어 3위")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    // MARK: - [헬퍼 서브뷰] 3. 나의 맛집 기록 헤더 & 3분할 탭 바
    private var recordSectionHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("나의 맛집 기록")
                .font(.title3.weight(.bold))
                .padding(.horizontal, 16)

            // 3분할 세그먼트 탭 (리뷰 | 다녀온 곳 | 가고 싶은 곳)
            HStack(spacing: 0) {
                tabButton(tab: .review, count: viewModel.reviewCount)
                tabButton(tab: .visited, count: viewModel.visitedCount)
                tabButton(tab: .wantToGo, count: viewModel.wantToGoCount)
            }
            .padding(.horizontal, 16)
        }
    }

    // 개별 탭 버튼 (오렌지 인디케이터 바)
    private func tabButton(tab: MyRecordTab, count: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                viewModel.selectedMyRecordTab = tab
            }
        } label: {
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Text(tab.rawValue)
                        .font(.subheadline.weight(viewModel.selectedMyRecordTab == tab ? .bold : .medium))
                    Text("\(count)")
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                }
                .foregroundStyle(viewModel.selectedMyRecordTab == tab ? Color.orange : Color.secondary)

                // 하단 인디케이터 바
                Rectangle()
                    .fill(viewModel.selectedMyRecordTab == tab ? Color.orange : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // HIG 44pt 보장
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - [헬퍼 서브뷰] 4. 음식 카테고리 필터 메뉴 & 뷰 모드 전환 버튼
    private var filterAndDisplayToolbar: some View {
        HStack {
            // 카테고리 드롭다운 메뉴
            Menu {
                ForEach(FoodCategory.allCases) { cat in
                    Button {
                        viewModel.myListCategory = cat
                    } label: {
                        HStack {
                            Text(cat.rawValue)
                            if viewModel.myListCategory == cat {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.caption)
                    Text(viewModel.myListCategory == .all ? "전체 음식" : viewModel.myListCategory.rawValue)
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(Capsule())
            }

            Spacer()

            // 뷰 모드 토글 (3열 그리드 vs 리스트)
            HStack(spacing: 2) {
                Button {
                    withAnimation { viewModel.myListViewMode = .grid }
                } label: {
                    Image(systemName: "square.grid.3x3")
                        .font(.subheadline)
                        .foregroundStyle(viewModel.myListViewMode == .grid ? Color.orange : Color.secondary)
                        .frame(width: 38, height: 38)
                        .contentShape(Rectangle())
                }

                Button {
                    withAnimation { viewModel.myListViewMode = .list }
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.subheadline)
                        .foregroundStyle(viewModel.myListViewMode == .list ? Color.orange : Color.secondary)
                        .frame(width: 38, height: 38)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - [헬퍼 서브뷰] 5-A. 3열 사진 그리드 (디자인 레퍼런스 스타일)
    private var photoGridView: some View {
        let columns = [
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible(), spacing: 4)
        ]

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(viewModel.myTabFilteredRestaurants) { item in
                Button {
                    onSelectRestaurant(item)
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        if let uiImage = UIImage(named: item.representativePhotoName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        } else {
                            Rectangle()
                                .fill(Color.orange.opacity(0.15))
                                .aspectRatio(1, contentMode: .fit)
                                .overlay(
                                    Image(systemName: item.category.iconName)
                                        .font(.title2)
                                        .foregroundStyle(Color.orange)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }

                        // 별점이 있는 경우 우하단 작은 배지 노출
                        if let rating = item.myRating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                Text("\(rating)")
                                    .font(.caption2.weight(.bold))
                                    .monospacedDigit()
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.65))
                            .clipShape(Capsule())
                            .padding(4)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - [헬퍼 서브뷰] 5-B. 리스트 뷰
    private var cardListView: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.myTabFilteredRestaurants) { item in
                MyRestaurantCard(
                    restaurant: item,
                    onTap: { onSelectRestaurant(item) },
                    onRatingChange: { newRating in
                        viewModel.updateMyRating(id: item.id, rating: newRating)
                    }
                )
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - [헬퍼 서브뷰] 빈 화면 안내
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 42))
                .foregroundStyle(.tertiary)
            Text("'\(viewModel.selectedMyRecordTab.rawValue)'에 등록된 식당이 없습니다.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text("주변 맛집이나 피드에서 마음에 드는 식당을 저장해보세요.")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.horizontal, 16)
    }
}

// MARK: - 프리뷰
#Preview("마이페이지 - 라이트") {
    MyRestaurantListView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
    .preferredColorScheme(.light)
}

#Preview("마이페이지 - 다크") {
    MyRestaurantListView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
    .preferredColorScheme(.dark)
}
