//
//  CategoryFilterBar.swift
//  project2
//
//  전체/한식/중식/일식/디저트 가로 스크롤 필터 칩 바 (좌측 정렬 적용)
//

import SwiftUI

// MARK: - 카테고리 필터 바 컴포넌트
struct CategoryFilterBar: View {
    // MARK: 선택된 카테고리 바인딩
    @Binding var selectedCategory: FoodCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 모든 음식 카테고리 순회 표시 (좌측부터 정렬)
                ForEach(FoodCategory.allCases) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    } label: {
                        Text(category.rawValue)
                            .font(.system(size: 13, weight: selectedCategory == category ? .bold : .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == category ? Color.orange : Color(uiColor: .secondarySystemBackground))
                            )
                            .foregroundStyle(selectedCategory == category ? Color.white : Color.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 44)
    }
}

#Preview("카테고리 필터 바") {
    @Previewable @State var selected: FoodCategory = .all
    CategoryFilterBar(selectedCategory: $selected)
        .padding(.vertical)
}
