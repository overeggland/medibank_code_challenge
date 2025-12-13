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
        let cachedSources = service.loadCachedSources()
        sources = cachedSources
        sources.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        
        // Set first 3 cached sources as default selected if available
        if !cachedSources.isEmpty {
            let firstThreeSources = Array(cachedSources.prefix(3))
            selectedSources = Set(firstThreeSources)
        }
    }

    func loadTopHeadlines(country: NewsCountry? = .us, category: NewsCategory? = .business, sources: String? = nil) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            // If sources are selected, use them; otherwise use country/category
            let sourcesString: String?
            let pageSize: Int
            
            if !selectedSources.isEmpty {
                // Combine all selected source IDs into comma-separated string
                let sourceIds = selectedSources.compactMap { $0.id }
                sourcesString = sourceIds.isEmpty ? nil : sourceIds.joined(separator: ",")
                // Request 10 articles per source
                pageSize = selectedSources.count * 10
            } else {
                sourcesString = sources
                pageSize = 10 // Default page size
            }
            
            articles = try await service.fetchTopHeadlines(country: country, category: category, sources: sourcesString, pageSize: pageSize)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func loadSources(country: NewsCountry? = .au) async {
        guard !isLoadingSources else { return }
        isLoadingSources = true
        sourcesErrorMessage = nil

        do {
            let fetchedSources = try await service.fetchSources(country: country)
            sources = fetchedSources
            sources.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            
            // Set first 3 fetched sources as default selected sources
            let shouldLoadArticles = !fetchedSources.isEmpty && selectedSources.isEmpty
            if shouldLoadArticles {
                let firstThreeSources = Array(fetchedSources.prefix(3))
                selectedSources = Set(firstThreeSources)
            }
            
            // Clear error message if we successfully got sources (even if from cache)
            if !sources.isEmpty {
                sourcesErrorMessage = nil
            }
            
            // Automatically load articles if we just set default sources
            if shouldLoadArticles {
                await loadTopHeadlines()
            }
        } catch {
            // If fetch fails, try to load from cache
            let cachedSources = service.loadCachedSources()
            if !cachedSources.isEmpty {
                sources = cachedSources
                sources.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                
                // Set first 3 cached sources as default selected if none are selected
                let shouldLoadArticles = selectedSources.isEmpty && !cachedSources.isEmpty
                if shouldLoadArticles {
                    let firstThreeSources = Array(cachedSources.prefix(3))
                    selectedSources = Set(firstThreeSources)
                }
                
                sourcesErrorMessage = nil
                
                // Automatically load articles if we just set default sources
                if shouldLoadArticles {
                    await loadTopHeadlines()
                }
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
