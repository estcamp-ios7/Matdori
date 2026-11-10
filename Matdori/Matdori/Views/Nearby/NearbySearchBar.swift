//
//  NearbySearchBar.swift
//  project2
//
//  주변 맛집 상단 위치 선택 드롭다운 및 통합 스마트 검색바 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 주변 맛집 상단 위치 및 검색창 (Apple HIG 준수)
struct NearbySearchBar: View {
    // MARK: 검색어 및 현재 위치 상태를 공유하는 맛집 뷰모델
    @Bindable var viewModel: RestaurantViewModel

    var body: some View {
        VStack(spacing: 0) {
            // MARK: 1. 상단 현재 위치 헤더 영역 (HIG 44pt 터치 영역 확보)
            HStack {
                // 광주 5대 상권 선택 메뉴 드롭다운
                Menu {
                    ForEach(GwangjuDistrict.selectableLocations) { district in
                        Button(district.rawValue) {
                            viewModel.currentLocation = district.rawValue
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.subheadline)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.orange)

                        Text("현재 위치:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // 현재 선택된 위치 텍스트 (Semantic Headline)
                        Text(viewModel.currentLocation)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.orange)
                    }
                    .frame(minHeight: 44) // Apple HIG 최소 터치 높이 44pt 보장
                    .contentShape(Rectangle())
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)

            // MARK: 2. 지역 & 음식 & 식당 통합 스마트 검색창 (HIG 텍스트 필드 규격)
            HStack(spacing: 8) {
                // 돋보기 계층형 SF Symbol
                Image(systemName: "magnifyingglass")
                    .font(.body)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.orange)

                // 검색어 입력 텍스트필드 (Semantic Callout)
                TextField("지역, 음식, 식당 검색 (예: 동명동, 오리탕)", text: $viewModel.searchQuery)
                    .font(.callout)
                    .submitLabel(.search)

                // 검색어가 입력되어 있을 때 초기화(X) 버튼 (44x44pt 터치 영역)
                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(width: 44, height: 44) // HIG 터치 타깃 충족
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 44) // HIG 필드 높이 규격 44pt
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - 프리뷰
#Preview("주변 맛집 검색바 - 라이트") {
    NearbySearchBar(viewModel: RestaurantViewModel())
        .padding(.vertical)
        .preferredColorScheme(.light)
}

#Preview("주변 맛집 검색바 - 다크") {
    NearbySearchBar(viewModel: RestaurantViewModel())
        .padding(.vertical)
        .preferredColorScheme(.dark)
}
