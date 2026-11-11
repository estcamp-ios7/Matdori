//
//  FeedDistrictFilterBar.swift
//  project2
//
//  피드 화면 상단 광주 상권/자치구 수평 스크롤 칩 필터 바 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - [서브뷰 컴포넌트] 피드 자치구 필터 바 (Apple HIG 준수)
struct FeedDistrictFilterBar: View {
    // MARK: 시스템 라이트/다크모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 피드 상권 필터 상태를 공유하는 맛집 뷰모델
    @Bindable var viewModel: RestaurantViewModel

    var body: some View {
        // 가로 스크롤 뷰 (인디케이터 숨김)
        ScrollView(.horizontal, showsIndicators: false) {
            // 자치구 칩 버튼 간 8포인트 간격의 가로 스택
            HStack(spacing: 8) {
                // 광주 5대 상권 및 '전체' 열거형 순회
                ForEach(GwangjuDistrict.allCases) { district in
                    Button {
                        // 애니메이션 딜레이 없이 즉각적인 자치구 필터 갱신
                        viewModel.selectedFeedDistrict = district
                    } label: {
                        // 자치구 명칭 텍스트 (Apple HIG Semantic Typography: subheadline)
                        Text(district.rawValue)
                            .font(.subheadline.weight(viewModel.selectedFeedDistrict == district ? .bold : .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .frame(minHeight: 44) // Apple HIG 최소 터치 높이 44pt 보장
                            // 배경색: 선택 시 오렌지, 미선택 시 보조 시스템 그룹 배경
                            .background(
                                viewModel.selectedFeedDistrict == district
                                ? Color.orange
                                : Color(uiColor: .secondarySystemGroupedBackground)
                            )
                            // 글자색: 선택 시 흰색, 미선택 시 기본 텍스트 색상
                            .foregroundStyle(
                                viewModel.selectedFeedDistrict == district
                                ? Color.white
                                : Color.primary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                // 미선택 상태일 때만 은은한 테두리 선 노출
                                Capsule()
                                    .stroke(
                                        viewModel.selectedFeedDistrict == district
                                        ? Color.clear
                                        : (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.06)),
                                        lineWidth: 1
                                    )
                            )
                            // 선택된 칩에만 오렌지 빛 그림자 효과 부여
                            .shadow(
                                color: viewModel.selectedFeedDistrict == district ? Color.orange.opacity(0.3) : Color.clear,
                                radius: 4,
                                x: 0,
                                y: 2
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
#Preview("피드 자치구 필터 바") {
    FeedDistrictFilterBar(viewModel: RestaurantViewModel())
        .padding(.vertical)
}
