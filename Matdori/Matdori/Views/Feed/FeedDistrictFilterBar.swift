//
//  FeedDistrictFilterBar.swift
//  project2
//
//  피드 화면 상단 광주광역시 자치구(동구, 서구, 남구, 북구, 광산구) 가로 스크롤 필터 바 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 피드 자치구 필터 바 (Apple HIG 준수)
struct FeedDistrictFilterBar: View {
    // MARK: 시스템 라이트/다크모드 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 피드 자치구 필터 상태를 공유하는 뷰모델
    @Bindable var viewModel: RestaurantViewModel

    var body: some View {
        // 가로 방향 스크롤 뷰 (스크롤 바 숨김)
        ScrollView(.horizontal, showsIndicators: false) {
            // 필터 칩 간 8포인트 간격의 가로 스택
            HStack(spacing: 8) {
                // 광주 5대 자치구 및 전체 옵션 순회
                ForEach(GwangjuDistrict.allCases) { district in
                    // 선택 여부에 따른 불리언 플래그
                    let isSelected = viewModel.selectedFeedDistrict == district

                    Button {
                        // 자치구 칩 선택 시 딜레이 없이 즉시 반영
                        viewModel.selectedFeedDistrict = district
                    } label: {
                        HStack(spacing: 4) {
                            // 계층형 SF Symbol 위치 아이콘 (선택 시 화이트, 미선택 시 오렌지)
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(isSelected ? Color.white : Color.orange)

                            // 자치구 명칭 텍스트 (Semantic Subheadline)
                            Text(district.rawValue)
                                .font(.subheadline.weight(isSelected ? .bold : .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .frame(minHeight: 44) // Apple HIG 최소 터치 높이 44pt 보장
                        // 선택된 칩은 오렌지 배경, 미선택 칩은 시스템 서브 배경색 적용
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.orange : Color(uiColor: .secondarySystemBackground))
                        )
                        // 선택 여부에 따른 글자색 대비 설정
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.clear : (colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .contentShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 52)
    }
}

// MARK: - 프리뷰
#Preview("피드 자치구 필터 바 - 라이트") {
    FeedDistrictFilterBar(viewModel: RestaurantViewModel())
        .padding(.vertical)
        .preferredColorScheme(.light)
}

#Preview("피드 자치구 필터 바 - 다크") {
    FeedDistrictFilterBar(viewModel: RestaurantViewModel())
        .padding(.vertical)
        .preferredColorScheme(.dark)
}
