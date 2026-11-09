//
//  RestaurantDetailView.swift
//  project2
//
//  식당 상세 정보 페이지 (노란 포스트잇 요구사항 완벽 반영, 나만의 별점 평가, 다크모드 대응)
//

import SwiftUI

// MARK: - 식당 상세페이지 화면
struct RestaurantDetailView: View {
    // MARK: 다크모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    // MARK: 뷰모델 바인딩
    @Bindable var viewModel: RestaurantViewModel

    // MARK: 대상 식당 정보
    var restaurant: Restaurant

    // MARK: 나의 맛집 리스트에서 진입했는지 여부 (나의 맛집에서 진입 시: +버튼 숨김 및 나만의 별점 섹션 노출)
    var openedFromMyList: Bool

    // MARK: 맛집 신규 추가 완료 알림창 상태
    @State private var showAddedAlert = false

    // MARK: 이미 저장된 가게 알림창 상태 (중복 저장 및 삭제 방지)
    @State private var showAlreadySavedAlert = false

    // MARK: 내가 준 별점 상태 (선택되지 않은 경우 nil)
    @State private var currentMyRating: Int?

    init(viewModel: RestaurantViewModel, restaurant: Restaurant, openedFromMyList: Bool) {
        self.viewModel = viewModel
        self.restaurant = restaurant
        self.openedFromMyList = openedFromMyList
        _currentMyRating = State(initialValue: restaurant.myRating)
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

                    // MARK: 2. 기본 정보 헤더 (이름, 카테고리, 기본 별점)
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

                        // 노란 포스트잇 요구사항: "기본 별점"
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

                    // MARK: 3. 나만의 별점 평가 섹션 (나의 맛집 리스트에서 진입했을 때만 노출)
                    if openedFromMyList {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                                    .foregroundStyle(Color.orange)
                                Text("나만의 별점 평가")
                                    .font(.system(size: 15, weight: .bold))
                                Spacer()
                                if let rating = currentMyRating {
                                    Text("\(rating) / 5")
                                        .font(.system(size: 14, weight: .bold))
                                        .monospacedDigit()
                                        .foregroundStyle(Color.orange)
                                } else {
                                    Text("별점을 선택해주세요")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                }
                            }

                            // 1~5점 별점 인터랙티브 수정
                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { star in
                                    Button {
                                        currentMyRating = star
                                        viewModel.updateMyRating(id: restaurant.id, rating: star)
                                    } label: {
                                        Image(systemName: (currentMyRating != nil && star <= (currentMyRating ?? 0)) ? "star.fill" : "star")
                                            .font(.system(size: 26))
                                            .foregroundStyle((currentMyRating != nil && star <= (currentMyRating ?? 0)) ? Color.orange : Color.gray.opacity(0.35))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)

                            if !restaurant.myNote.isEmpty {
                                Text("내 메모: \(restaurant.myNote)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(14)
                        .background(Color.orange.opacity(colorScheme == .dark ? 0.15 : 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                    }

                    Divider().padding(.horizontal, 16)

                    // MARK: 4. 상세 정보 섹션 (주소, 오픈/마감시간, 전화번호) (포스트잇 요구사항)
                    VStack(alignment: .leading, spacing: 12) {
                        infoRow(icon: "mappin.circle.fill", label: "주소", content: restaurant.address)
                        infoRow(icon: "clock.fill", label: "영업시간", content: restaurant.openCloseTime)
                        infoRow(icon: "phone.fill", label: "전화번호", content: restaurant.phoneNumber)
                        infoRow(icon: "car.fill", label: "주차안내", content: restaurant.parkingInfo)
                    }
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)

                    // MARK: 5. 메뉴 및 가격 섹션 (포스트잇 요구사항: 메뉴(가격))
                    VStack(alignment: .leading, spacing: 10) {
                        Text("메뉴 및 가격")
                            .font(.system(size: 16, weight: .bold))

                        VStack(spacing: 0) {
                            ForEach(restaurant.menus) { menu in
                                HStack {
                                    HStack(spacing: 6) {
                                        Text(menu.name)
                                            .font(.system(size: 14, weight: menu.isSignature ? .bold : .regular))
                                        if menu.isSignature {
                                            Text("대표")
                                                .font(.system(size: 10, weight: .bold))
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 2)
                                                .background(Color.orange)
                                                .foregroundStyle(.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                        }
                                    }
                                    Spacer()
                                    Text(menu.price)
                                        .font(.system(size: 14, weight: .semibold))
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 10)

                                if menu.id != restaurant.menus.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding(14)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)

                    // MARK: 6. 실제 방문자 리뷰 섹션 (개인적인 경험과 평가 공유, SNS 배지 제거)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("실제 방문자 리뷰")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                            Text("\(restaurant.reviews.count)개")
                                .font(.system(size: 13))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }

                        ForEach(restaurant.reviews) { rev in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: rev.authorAvatar)
                                        .font(.system(size: 18))
                                        .foregroundStyle(.orange)
                                    Text(rev.authorName)
                                        .font(.system(size: 13, weight: .bold))
                                    Spacer()
                                    Text(rev.visitDate)
                                        .font(.system(size: 11))
                                        .foregroundStyle(.tertiary)
                                }

                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= Int(rev.rating) ? "star.fill" : "star")
                                            .font(.system(size: 10))
                                            .foregroundStyle(Color.orange)
                                    }
                                }

                                Text(rev.content)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.primary)
                            }
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .navigationTitle("식당 상세페이지")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 뒤로가기 버튼
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }

                // 포스트잇 스펙: "나의 맛집 리스트에서 진입 시 플러스버튼 삭제", 일반 탐색 시에는 (+) 표시로 저장
                // 중복 저장 방지: 이미 저장된 경우 삭제되지 않고 "이미 저장된 가게입니다" 알림 노출
                ToolbarItem(placement: .topBarTrailing) {
                    if !openedFromMyList {
                        Button {
                            let isNewlySaved = viewModel.saveRestaurant(id: restaurant.id)
                            if isNewlySaved {
                                showAddedAlert = true
                            } else {
                                showAlreadySavedAlert = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.orange)
                        }
                    }
                }
            }
            // 와이어프레임 중앙 알림창: "나의 맛집에 추가되었습니다!" (확인 터치 시 시트 닫힘)
            .alert("나의 맛집에 추가되었습니다!", isPresented: $showAddedAlert) {
                Button("확인", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("'나의 맛집'에 저장되었습니다.")
            }
            // 중복 저장 시 알림창: "이미 저장된 가게입니다" (식당 삭제 방지 및 확인 터치 시 시트 닫힘)
            .alert("이미 저장된 가게입니다", isPresented: $showAlreadySavedAlert) {
                Button("확인", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("'나의 맛집' 리스트에 이미 등록되어 있습니다.")
            }
        }
    }

    // 세부 안내 정보 행 헬퍼
    private func infoRow(icon: String, label: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.orange)
                .frame(width: 18)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 65, alignment: .leading)
            Text(content)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}

#Preview("상세페이지 (주변/피드 탐색 진입 - +버튼 노출, 나만의 별점 숨김)") {
    let vm = RestaurantViewModel()
    RestaurantDetailView(
        viewModel: vm,
        restaurant: vm.restaurants[0],
        openedFromMyList: false
    )
    .preferredColorScheme(.light)
}

#Preview("상세페이지 (나의 맛집 리스트 진입 - +버튼 숨김, 나만의 별점 노출)") {
    let vm = RestaurantViewModel()
    RestaurantDetailView(
        viewModel: vm,
        restaurant: vm.restaurants[1],
        openedFromMyList: true
    )
    .preferredColorScheme(.light)
}
