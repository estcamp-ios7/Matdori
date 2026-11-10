//
//  CustomTabBar.swift
//  project2
//
//  커스텀 하단 플로팅 탭바 (Apple HIG 터치 타깃 및 Dynamic Type 규격 준수)
//

import SwiftUI

// MARK: - 앱 주요 탭 열거형
enum AppTab: String, CaseIterable {
    case map = "주변 맛집"
    case feed = "피드"
    case myPage = "나의 맛집"
}

// MARK: - 플로팅 탭바 뷰 컴포넌트
struct CustomTabBar: View {
    // MARK: 시스템 라이트/다크 모드 환경 감지
    @Environment(\.colorScheme) private var colorScheme

    // MARK: 현재 선택된 탭 바인딩
    @Binding var selectedTab: AppTab

    // MARK: 이미 활성화된 탭을 다시 탭했을 때 호출되는 이벤트 핸들러 클로저
    var onReselectTab: ((AppTab) -> Void)? = nil

    var body: some View {
        // 탭 버튼들을 32포인트 간격으로 수평 배치
        HStack(spacing: 32) {
            // 1. 주변 맛집 탭 버튼
            tabButton(title: "주변 맛집", icon: "map.fill", tab: .map)

            // 2. 피드 탭 버튼
            tabButton(title: "피드", icon: "bubble.left.and.bubble.right", tab: .feed)

            // 3. 나의 맛집 탭 버튼
            tabButton(title: "나의 맛집", icon: "bookmark.fill", tab: .myPage)
        }
        // 탭바 내부 좌우 및 상하 여백 설정
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        // 플로팅 캡슐 형태의 배경 및 테두리 효과
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

    // MARK: - [헬퍼 메서드] 단일 탭 버튼 빌더 (Apple HIG 준수)
    private func tabButton(title: String, icon: String, tab: AppTab) -> some View {
        Button {
            if selectedTab == tab {
                // 이미 활성화된 탭을 다시 눌렀을 때 상위로 재선택 이벤트 전달
                onReselectTab?(tab)
            } else {
                // 새로운 탭으로의 부드러운 스프링 전환 애니메이션
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = tab
                }
            }
        } label: {
            VStack(spacing: 3) {
                // 계층형 렌더링 적용된 SF Symbol 아이콘
                Image(systemName: icon)
                    .font(.system(size: 19, weight: selectedTab == tab ? .bold : .regular))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(selectedTab == tab ? Color.orange : Color.secondary)

                // Semantic Typography (caption2) 적용
                Text(title)
                    .font(.caption2.weight(selectedTab == tab ? .bold : .medium))
                    .foregroundStyle(selectedTab == tab ? Color.orange : Color.secondary)
            }
            .frame(minWidth: 48, minHeight: 44) // Apple HIG 최소 터치 규격 44x44pt 보장
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 프리뷰
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
