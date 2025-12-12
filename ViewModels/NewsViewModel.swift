import Foundation

@MainActor
final class NewsViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var selectedSources: Set<Article.Source> = []

    private let service: NewsServicing

    init(service: NewsServicing) {
        self.service = service
    }

    func loadTopHeadlines(country: NewsCountry = .us, category: NewsCategory? = .business) async {
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
    
    /// Articles filtered by selected sources. If no sources are selected, returns all articles.
    var filteredArticles: [Article] {
        if selectedSources.isEmpty {
            return articles
        }
        return articles.filter { selectedSources.contains($0.source) }
    }
    
    func toggleSourceSelection(_ source: Article.Source) {
        if selectedSources.contains(source) {
            selectedSources.remove(source)
        } else {
            selectedSources.insert(source)
        }
    }
    
    func isSourceSelected(_ source: Article.Source) -> Bool {
        selectedSources.contains(source)
    }
    
    func clearSourceSelection() {
        selectedSources.removeAll()
    }
}
