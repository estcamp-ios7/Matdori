//
//  CustomTabBar.swift
//  project2
//
//  커스텀 하단 플로팅 탭바 (다크모드 대응)
//

import SwiftUI

// MARK: - 앱 주요 탭 열거형
enum AppTab: String, CaseIterable {
    case map = "주변 맛집"
    case feed = "피드"
    case myPage = "나의 맛집"
}

// MARK: - 플로팅 탭바 뷰
struct CustomTabBar: View {
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 현재 선택된 탭 바인딩
    @Binding var selectedTab: AppTab

    // MARK: [이벤트 핸들러] 이미 활성화된 탭을 다시 탭했을 때 호출되는 클로저 (루트 화면 복귀 등)
    var onReselectTab: ((AppTab) -> Void)? = nil

    var body: some View {
        HStack(spacing: 36) {
            tabButton(title: "주변 맛집", icon: "map.fill", tab: .map)
            tabButton(title: "피드", icon: "newspaper.fill", tab: .feed)
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
            if selectedTab == tab {
                // 이미 활성화된 탭을 다시 눌렀을 때 재선택 이벤트 전달 (예: 피드 탭 메인 복귀)
                onReselectTab?(tab)
            } else {
                // 새로운 탭으로의 전환 애니메이션
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = tab
                }
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
