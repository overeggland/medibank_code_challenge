import Foundation

@MainActor
final class NewsViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: NewsServicing

    init(service: NewsServicing) {
        self.service = service
    }

    func loadTopHeadlines(country: String = "us", category: String? = "business") async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            articles = try await service.fetchTopHeadlines(country: country, category: category)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Unique list of sources across the currently loaded articles, sorted by name.
    var sources: [Article.Source] {
        Array(Set(articles.map { $0.source }))
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
