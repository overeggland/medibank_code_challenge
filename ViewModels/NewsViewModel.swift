import Foundation

@MainActor
final class NewsViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var sources: [Article.Source] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingSources = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var sourcesErrorMessage: String?
    @Published var selectedSources: Set<Article.Source> = []

    private let service: NewsServicing

    init(service: NewsServicing) {
        self.service = service
        // Load cached sources immediately on init
        sources = service.loadCachedSources()
        sources.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
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
    
    func loadSources() async {
        guard !isLoadingSources else { return }
        isLoadingSources = true
        sourcesErrorMessage = nil

        do {
            let fetchedSources = try await service.fetchSources()
            sources = fetchedSources
            sources.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            // Clear error message if we successfully got sources (even if from cache)
            if !sources.isEmpty {
                sourcesErrorMessage = nil
            }
        } catch {
            // If fetch fails, try to load from cache
            let cachedSources = service.loadCachedSources()
            if !cachedSources.isEmpty {
                sources = cachedSources
                sources.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                sourcesErrorMessage = nil
            } else {
                sourcesErrorMessage = error.localizedDescription
            }
        }

        isLoadingSources = false
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
