//
//  NearbyMapView.swift
//  project2
//
//  Apple MapKit 기반 주변 맛집 지도 탐색 및 통합 검색/정렬 화면
//

import SwiftUI
import MapKit

// MARK: - [메인 화면] 주변 맛집 탐색 뷰
/// 애플 맵킷(MapKit)을 통해 실제 광주광역시 지도 위에 식당 위치 핀을 띄우고,
/// 상단 스마트 검색창, 카테고리 필터, 거리순/평점순 정렬 피커 및 하단 맛집 리스트를 제공하는 화면입니다.
struct NearbyMapView: View {
    // MARK: [뷰모델 바인딩] 식당 목록 데이터, 현재 위치, 검색 쿼리, 정렬 옵션 및 필터링 상태 공유
    @Bindable var viewModel: RestaurantViewModel

    // MARK: [이벤트 핸들러] 지도 핀 또는 리스트 행 탭 시 식당 상세 모달 시트를 띄우는 클로저
    var onSelectRestaurant: (Restaurant) -> Void

    // MARK: [더미 위치 목록] 사용자가 선택할 수 있는 광주광역시 주요 5대 상권 및 법정동
    let sampleLocations = ["용봉동", "동명동", "상무지구", "수완지구", "양림동"]

    // MARK: [좌표 맵핑 테이블] 상단 위치 변경 시 지도 카메라가 자동 이동할 중심 위도/경도 좌표 사전
    private let locationCoordinates: [String: CLLocationCoordinate2D] = [
        "용봉동": CLLocationCoordinate2D(latitude: 35.1765, longitude: 126.9080), // 전남대 및 북구 용봉동 상권
        "동명동": CLLocationCoordinate2D(latitude: 35.1485, longitude: 126.9240), // 동구 동명동 카페의 거리
        "상무지구": CLLocationCoordinate2D(latitude: 35.1530, longitude: 126.8510), // 서구 치평동 상무 중심 상권
        "수완지구": CLLocationCoordinate2D(latitude: 35.1910, longitude: 126.8220), // 광산구 수완 호수공원 상권
        "양림동": CLLocationCoordinate2D(latitude: 35.1380, longitude: 126.9140)  // 남구 펭귄마을 역사문화거리 상권
    ]

    // MARK: [MapKit 카메라 상태] 지도의 초기 줌 레벨 및 중심 좌표 설정 (초기값: 광주 용봉동 일대)
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.1765, longitude: 126.9080), // 북구 용봉동 중심
            span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)     // 주변 2~3km 반경을 보여주는 줌 배율
        )
    )

    var body: some View {
        // 화면 전체를 세로로 배치하는 메인 컨테이너 (간격 0)
        VStack(spacing: 0) {
            // MARK: 1. 상단 현재 위치 헤더 영역
            HStack {
                // 사용자가 탭하여 가상 위치를 즉시 변경할 수 있는 드롭다운 메뉴
                Menu {
                    // 지원하는 5개 상권 목록을 순회하며 메뉴 버튼 생성
                    ForEach(sampleLocations, id: \.self) { loc in
                        Button(loc) {
                            // 뷰모델의 현재 위치 상태 업데이트 (지도 카메라 및 거리 동기화)
                            viewModel.currentLocation = loc
                        }
                    }
                } label: {
                    // 상단 헤더 라벨: 위치 핀 아이콘 + '현재 위치:' + 동명 + 드롭다운 화살표
                    HStack(spacing: 4) {
                        // 위치를 상징하는 오렌지색 채움 핀 아이콘
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.orange)

                        // 고정 보조 문구
                        Text("현재 위치: ")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.secondary)

                        // 현재 선택된 위치 텍스트 (예: '용봉동')
                        Text(viewModel.currentLocation)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)

                        // 드롭다운 가능함을 알리는 하향 화살표
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.orange)
                    }
                    .padding(.vertical, 4) // 터치 영역 세로 패딩
                }

                // 우측 여백을 밀어내어 좌측 정렬 유지
                Spacer()
            }
            .padding(.horizontal, 16) // 좌우 16pt 기본 여백
            .padding(.top, 8)         // Safe Area 바로 아래에 자연스럽게 위치하도록 상단 8pt 설정
            .padding(.bottom, 6)      // 검색창과의 하단 여백

            // MARK: 2. 지역 & 음식 & 식당 통합 스마트 검색창
            HStack(spacing: 8) {
                // 검색창 좌측 돋보기 아이콘
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.orange)

                // 실시간 양방향 바인딩 텍스트 필드 (식당명, 동/구 이름, 메뉴명 동시 검색)
                TextField("지역, 음식, 식당 검색 (예: 동명동, 오리탕)", text: $viewModel.searchQuery)
                    .font(.system(size: 14))
                    .submitLabel(.search) // 키보드 우하단에 '검색' 완료 버튼 표시

                // 검색어가 한 글자라도 입력된 경우 노출되는 텍스트 즉시 삭제(X) 버튼
                if !viewModel.searchQuery.isEmpty {
                    Button {
                        // 검색어 초기화
                        viewModel.searchQuery = ""
                    } label: {
                        // 원형 X 심볼 아이콘
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain) // 기본 버튼 탭 애니메이션 제거
                }
            }
            .padding(.horizontal, 12)                                        // 텍스트필드 내부 좌우 여백
            .padding(.vertical, 9)                                          // 텍스트필드 내부 상하 높이감
            .background(Color(uiColor: .tertiarySystemGroupedBackground))   // iOS 시스템 계층형 배경색
            .clipShape(RoundedRectangle(cornerRadius: 10))                   // 둥근 사각 모서리 클리핑
            .padding(.horizontal, 16)                                        // 화면 좌우 16pt 여백
            .padding(.bottom, 8)                                            // 하단 카테고리 필터바와의 간격

            // MARK: 3. 카테고리 필터 바 (전체, 한식, 중식, 일식, 디저트 등)
            CategoryFilterBar(selectedCategory: $viewModel.selectedCategory)
                .padding(.bottom, 8) // 지도와의 하단 여백

            // MARK: 4. MapKit 기반 실제 지도 뷰 (식당별 커스텀 원형 핀 마커)
            Map(position: $cameraPosition) {
                // 현재 검색/카테고리/정렬 조건에 맞게 필터링된 식당 목록을 순회
                ForEach(viewModel.filteredNearbyRestaurants) { item in
                    // 식당의 실제 위도/경도 좌표에 커스텀 마커 렌더링 (타이틀 배지는 생략하여 깔끔함 유지)
                    Annotation("", coordinate: item.coordinate) {
                        Button {
                            // 핀 터치 시 해당 식당의 탐색 상세 시트 오픈
                            onSelectRestaurant(item)
                        } label: {
                            // 오렌지 원형 맛도리 시그니처 핀 마커
                            ZStack {
                                // 1) 흰색 외곽 원형 베이스 (가시성 및 그림자 확보)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 30, height: 30)
                                    .shadow(color: .black.opacity(0.22), radius: 3, x: 0, y: 2)

                                // 2) 오렌지색 메인 원형 배경
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 25, height: 25)

                                // 3) 음식 카테고리에 맞는 SF Symbol 아이콘 (식사류는 수저/포크, 디저트는 커피잔)
                                Image(systemName: item.category.iconName)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.plain) // 탭 시 깜빡임 없는 플레인 스타일
                    }
                }
            }
            .mapControls {
                // 지도 우측 상단 나침반 컨트롤
                MapCompass()
                // 지도 축척 비율 스케일 뷰
                MapScaleView()
            }
            .frame(height: 270) // 지도를 시원하게 확대하여 도로 및 마커 시인성 대폭 강화 (270pt)
            .clipShape(RoundedRectangle(cornerRadius: 16)) // 부드러운 둥근 모서리
            .overlay(
                // 은은한 회색 테두리 라인
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 16) // 화면 좌우 16pt 여백
            .padding(.bottom, 44)     // 지도 조작 시 하단 정렬 필터 버튼과의 오터치를 방지하기 위한 44pt 간격 확보
            // 상단에서 위치 변경 시(용봉동 -> 동명동 등), 지도 카메라를 해당 지역 중심 좌표로 부드럽게 자동 패닝
            .onChange(of: viewModel.currentLocation) { _, newLoc in
                if let coord = locationCoordinates[newLoc] {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: coord,
                                span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
                            )
                        )
                    }
                }
            }

            // MARK: 5. 맛집 목록 헤더 (검색 결과 카운트 & 거리순/평점순 정렬 피커)
            HStack {
                // 현재 조건에 부합하는 맛집 총 개수 노출
                Text("맛집 \(viewModel.filteredNearbyRestaurants.count)개")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)

                // 좌우 분할 스페이서
                Spacer()

                // 거리순 / 평점순 정렬 옵션 선택 드롭다운 메뉴
                Menu {
                    // 거리순, 평점순 케이스를 순회하며 메뉴 항목 구성
                    ForEach(NearbySortOption.allCases) { option in
                        Button {
                            // 정렬 기준 변경 (선택 즉시 리스트 및 지도 순서 재배열)
                            viewModel.sortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                // 현재 선택된 옵션 옆에 체크마크 표시
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    // 정렬 버튼 라벨: [아이콘 + 거리순/평점순 텍스트 + 하향 화살표]
                    HStack(spacing: 5) {
                        // 정렬 기준에 맞는 심볼 (거리순: location.fill, 평점순: star.fill)
                        Image(systemName: viewModel.sortOption.iconName)
                            .font(.system(size: 12))

                        // 정렬 옵션명 ("거리순" 또는 "평점순")
                        Text(viewModel.sortOption.rawValue)
                            .font(.system(size: 13, weight: .bold))

                        // 드롭다운 셰브론 아이콘
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .padding(.horizontal, 14)                                // 캡슐 내부 좌우 패딩
                    .frame(minWidth: 44, minHeight: 44)                      // Apple HIG 표준 최소 터치 규격 44x44pt 보장
                    .background(Color.orange.opacity(0.12))                  // 부드러운 오렌지 틴트 배경
                    .foregroundStyle(Color.orange)                           // 오렌지 텍스트/아이콘 색상
                    .clipShape(Capsule())                                    // 캡슐 라운드 모양
                    .contentShape(Rectangle())                               // 44x44 전체 영역을 터치 반응 영역으로 인식
                }
            }
            .padding(.horizontal, 16) // 화면 좌우 16pt 여백
            .padding(.vertical, 2)    // 상하 미세 정렬 여백

            // MARK: 6. 하단 맛집 목록 리스트 (검색 결과 및 정렬 실시간 반영)
            if viewModel.filteredNearbyRestaurants.isEmpty {
                // 검색 결과가 0건일 때 나타나는 친절한 안내 뷰
                VStack(spacing: 12) {
                    Spacer()

                    // 반투명 돋보기 아이콘
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 38))
                        .foregroundStyle(Color.secondary.opacity(0.5))

                    // 주요 안내 타이틀
                    Text("조건에 맞는 맛집이 없습니다.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)

                    // 부가 제안 문구
                    Text("다른 검색어나 카테고리를 선택해 보세요.")
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 60) // 하단 플로팅 탭바 영역 확보
            } else {
                // 검색 결과가 존재할 때 표시되는 스크롤 가능한 식당 리스트
                List {
                    ForEach(viewModel.filteredNearbyRestaurants) { item in
                        // 식당 개별 행 뷰 컴포넌트
                        NearbyRestaurantRow(restaurant: item)
                            .contentShape(Rectangle()) // 행 전체를 터치 가능 영역으로 설정
                            .onTapGesture {
                                // 행 터치 시 식당 상세 모달 시트 오픈
                                onSelectRestaurant(item)
                            }
                            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)) // 행 내부 여백
                            .listRowSeparator(.visible, edges: .bottom)                               // 하단 구분선 유지
                    }
                }
                .listStyle(.automatic) // 플랫폼 기본 리스트 스타일
                .padding(.bottom, 60)  // 하단 플로팅 탭바와 겹치지 않도록 안전 여백 부여
            }
        }
        // 화면 전체 배경색 설정 (다크/라이트 모드 대응 세컨더리 시스템 배경)
        .background(Color(uiColor: .secondarySystemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - [컴포넌트] 주변 맛집 리스트 단일 행 뷰
/// 식당 이름, 별점, 저장 상태 배지, 카테고리, 자치구, 대표 메뉴 및 거리를 카드 행 형태로 표시합니다.
struct NearbyRestaurantRow: View {
    // MARK: 표시할 식당 데이터 모델
    let restaurant: Restaurant

    var body: some View {
        HStack(spacing: 12) {
            // 좌측 정보 영역 (식당명, 평점, 태그, 카테고리, 메뉴명)
            VStack(alignment: .leading, spacing: 4) {
                // 상단: 식당 이름 + 별점 + 저장됨 배지
                HStack(spacing: 6) {
                    // 식당 상호명
                    Text(restaurant.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)

                    // 기본 평점 표시 (예: ★ 4.8)
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)

                        Text(String(format: "%.1f", restaurant.baseRating))
                            .font(.system(size: 12, weight: .semibold))
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                    }

                    // 사용자가 저장(북마크)한 식당인 경우 오렌지색 '저장됨' 배지 노출
                    if restaurant.isSaved {
                        Text("저장됨")
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }

                // 하단 보조 정보: 카테고리 • 자치구 • 대표 시그니처 메뉴명
                HStack(spacing: 4) {
                    // 카테고리 (한식, 일식 등)
                    Text(restaurant.category.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.orange)

                    // 구분점
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)

                    // 광주 자치구 (동구, 북구 등)
                    Text(restaurant.district.rawValue)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    // 대표 시그니처 메뉴명이 존재할 경우 함께 노출하여 음식 검색 시 직관성 향상
                    if let signatureMenu = restaurant.menus.first(where: { $0.isSignature }) ?? restaurant.menus.first {
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)

                        Text(signatureMenu.name)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .lineLimit(1) // 한 줄 말줄임 처리
                    }
                }
            }

            // 좌우 분할 스페이서
            Spacer()

            // 우측: 거리 텍스트 및 상세 이동 화살표
            HStack(spacing: 4) {
                // 현재 위치로부터의 거리 (예: "100m", "1.2km")
                Text(restaurant.distanceText)
                    .font(.system(size: 13, weight: .medium))
                    .monospacedDigit() // 숫자 폭 고정으로 정렬 유지
                    .foregroundStyle(.secondary)

                // 우측 화살표 셰브론 아이콘
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.gray.opacity(0.6))
            }
        }
        .padding(.vertical, 4) // 행 상하 패딩
    }
}

// MARK: - [Xcode 프리뷰]
#Preview("주변 맛집 지도 화면") {
    NearbyMapView(
        viewModel: RestaurantViewModel(),
        onSelectRestaurant: { _ in }
    )
}
