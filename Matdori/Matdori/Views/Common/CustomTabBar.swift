//
//  CustomTabBar.swift
//  project2
//
//  커스텀 하단 플로팅 탭바 (다크모드 대응)
//

import SwiftUI

// MARK: - 앱 주요 탭 열거형
enum AppTab: String, CaseIterable {
    case feed = "피드"
    case map = "주변 맛집"
    case myPage = "나의 맛집"
}

// MARK: - 플로팅 탭바 뷰
struct CustomTabBar: View {
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 현재 선택된 탭 바인딩
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 40) {
            tabButton(title: "피드", icon: "bubble.left.and.bubble.right.fill", tab: .feed)
            tabButton(title: "주변 맛집", icon: "map.fill", tab: .map)
            tabButton(title: "나의 맛집", icon: "bookmark.fill", tab: .myPage)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.12), radius: 10, x: 0, y: 4)
                .overlay(
                    Capsule()
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.12) : Color.gray.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // 탭 개별 버튼 빌더
    private func tabButton(title: String, icon: String, tab: AppTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: selectedTab == tab ? .bold : .regular))
                    .foregroundStyle(selectedTab == tab ? Color.orange : Color.secondary)

                Text(title)
                    .font(.system(size: 11, weight: selectedTab == tab ? .bold : .medium))
                    .foregroundStyle(selectedTab == tab ? Color.orange : Color.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview("플로팅 탭바 - 라이트") {
    @Previewable @State var currentTab: AppTab = .map
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        CustomTabBar(selectedTab: $currentTab)
    }
    .preferredColorScheme(.light)
}

#Preview("플로팅 탭바 - 다크") {
    @Previewable @State var currentTab: AppTab = .map
    ZStack {
        Color.black.ignoresSafeArea()
        CustomTabBar(selectedTab: $currentTab)
    }
    .preferredColorScheme(.dark)
}
