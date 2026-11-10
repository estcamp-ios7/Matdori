//
//  MatdoriApp.swift
//  project2
//
//  Created by Jang Ho on 11/5/26.
//  맛도리 앱의 진입점 (App 메인 라이프사이클)
//

import SwiftUI

// MARK: - 앱 진입점 메인 구조체
@main
struct MatdoriApp: App {
    // MARK: 앱의 메인 씬 정의
    var body: some Scene {
        // 단일 윈도우 그룹 구성
        WindowGroup {
            // 루트 뷰로 ContentView 지정
            ContentView()
        }
    }
}
