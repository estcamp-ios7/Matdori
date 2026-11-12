import SwiftUI

struct RestaurantDetailView: View {
    @Bindable var viewModel: RestaurantViewModel
    let restaurant: Restaurant

    @State private var showAddedToast = false
    @State private var showAlreadySavedAlert = false
    @State private var selectedReview: CommunityReview?

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    topMapWireframeView
                        .padding(.horizontal, 16)

                    basicInfoHeader
                        .padding(.horizontal, 16)

                    Divider()
                        .padding(.horizontal, 16)

                    RestaurantInfoSection(restaurant: restaurant)
                        .padding(.horizontal, 16)

                    RestaurantMenuSection(restaurant: restaurant)
                        .padding(.horizontal, 16)

                    reviewsSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .navigationTitle("식당 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.saveRestaurant(id: restaurant.id) {
                            showAddedToast = true
                            Task {
                                try? await Task.sleep(for: .seconds(2.2))
                                showAddedToast = false
                            }
                        } else {
                            showAlreadySavedAlert = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.orange)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .alert("이미 저장된 가게입니다", isPresented: $showAlreadySavedAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("'나의 맛집' 리스트에 이미 등록되어 있습니다.")
            }
            .sheet(item: $selectedReview) { review in
                ReviewFullContentSheet(restaurant: restaurant, review: review)
                    .presentationDetents([.medium, .large])
            }

            if showAddedToast {
                Label("나의 맛집에 추가했어요", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.black.opacity(0.82))
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showAddedToast)
    }

    private var topMapWireframeView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                .frame(height: 180)

            VStack(spacing: 8) {
                Image(systemName: "map")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("지도 영역: \(restaurant.name)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var basicInfoHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text(restaurant.name)
                    .font(.title2.weight(.bold))
                    .lineLimit(2)

                Spacer(minLength: 12)

                Text(restaurant.category.rawValue)
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.14))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            }

            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { idx in
                        Image(systemName: idx <= Int(restaurant.baseRating) ? "star.fill" : (Double(idx) - 0.5 <= restaurant.baseRating ? "star.leadinghalf.filled" : "star"))
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                Text(String(format: "%.1f", restaurant.baseRating))
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.orange)

                Text("방문자 평가 평균")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("진솔한 방문자 리뷰")
                    .font(.title3.weight(.bold))

                Text("\(restaurant.reviews.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()
            }

            if let representativeReview = restaurant.reviews.max(by: { $0.helpfulCount < $1.helpfulCount }) {
                Text("가장 도움이 된 리뷰")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                reviewCard(representativeReview, isFeatured: true)
            }

            ForEach(restaurant.reviews) { review in
                if review.id != restaurant.reviews.max(by: { $0.helpfulCount < $1.helpfulCount })?.id {
                    reviewCard(review, isFeatured: false)
                }
            }
        }
    }

    private func reviewCard(_ review: CommunityReview, isFeatured: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: review.authorAvatar)
                    .font(.subheadline)
                    .foregroundStyle(.orange)

                Text(review.authorName)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text(review.visitDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text(String(format: "%.1f", review.rating))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.orange)
            }

            Text(review.content)
                .font(.body)
                .lineSpacing(3)
                .lineLimit(2)

            HStack {
                Label("\(review.helpfulCount)", systemImage: "hand.thumbsup.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                Text("도움이 됐어요")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("더보기") {
                    selectedReview = review
                    
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.orange)
            }
        }
        .padding(14)
        .background(isFeatured ? Color.orange.opacity(0.08) : Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            if isFeatured {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            }
        }
    }
}

private struct ReviewFullContentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let restaurant: Restaurant
    let review: CommunityReview
    @State private var isHelpful = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(restaurant.name)
                        .font(.title3.weight(.bold))

                    HStack {
                        Label(review.authorName, systemImage: review.authorAvatar)
                        Spacer()
                        Text(review.visitDate)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)

                    Text(review.content)
                        .font(.body)
                        .lineSpacing(6)

                    Button {
                        isHelpful.toggle()
                    } label: {
                        Label(
                            isHelpful ? "도움이 됐어요 \(review.helpfulCount + 1)" : "도움이 됐어요 \(review.helpfulCount)",
                            systemImage: isHelpful ? "hand.thumbsup.fill" : "hand.thumbsup"
                        )
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
            .navigationTitle("리뷰 전체보기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}

#Preview("식당 상세") {
    NavigationStack {
        RestaurantDetailView(
            viewModel: RestaurantViewModel(),
            restaurant: RestaurantViewModel().restaurants[0]
        )
    }
}
