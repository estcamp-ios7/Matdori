//
//  CategoryFilterBar.swift
//  project2
//
//  전체/한식/중식/일식/양식/디저트/기타 가로 스크롤 필터 칩 바 (Apple HIG 규격화)
//

import SwiftUI

// MARK: - 카테고리 필터 바 컴포넌트 (Apple HIG 준수)
struct CategoryFilterBar: View {
    // MARK: 선택된 음식 카테고리 바인딩
    @Binding var selectedCategory: FoodCategory

    var body: some View {
        // 가로 방향 스크롤 뷰 (스크롤 인디케이터 숨김)
        ScrollView(.horizontal, showsIndicators: false) {
            // 필터 칩 간 8포인트 간격의 가로 스택
            HStack(spacing: 8) {
                // FoodCategory 열거형 순회
                ForEach(FoodCategory.allCases) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    } label: {
                        // Apple HIG Semantic Typography 적용
                        Text(category.rawValue)
                            .font(.subheadline.weight(selectedCategory == category ? .bold : .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .frame(minHeight: 44) // Apple HIG 최소 터치 높이 44pt 보장
                            .background(
                                Capsule()
                                    .fill(selectedCategory == category ? Color.orange : Color(uiColor: .secondarySystemBackground))
                            )
                            .foregroundStyle(selectedCategory == category ? Color.white : Color.primary)
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
#Preview("카테고리 필터 바") {
    @Previewable @State var selected: FoodCategory = .all
    CategoryFilterBar(selectedCategory: $selected)
        .padding(.vertical)
}
