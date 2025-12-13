import Foundation

@MainActor
final class NewsViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var sources: [Article.Source] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingSources = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var sourcesErrorMessage: String?
    @Published var selectedSources: Set<Article.Source> = [] {
        didSet {
            saveSelectedSources()
        }
    }

    private let service: NewsServicing
    private let userDefaults: UserDefaults
    private let selectedSourcesKey = "selectedSources"

    init(service: NewsServicing, userDefaults: UserDefaults = .standard) {
        self.service = service
        self.userDefaults = userDefaults
        
        // Load cached sources immediately on init
        let cachedSources = service.loadCachedSources()
        sources = cachedSources
        sources.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        
        // Load persisted selected sources, or use first 3 as default
        if let savedSelectedSources = loadSelectedSources(), !savedSelectedSources.isEmpty {
            // Only use saved sources that still exist in the current sources list
            let validSources = savedSelectedSources.filter { savedSource in
                cachedSources.contains(savedSource)
            }
            if !validSources.isEmpty {
                selectedSources = Set(validSources)
            } else {
                // If no valid saved sources, use default count as default
                if !cachedSources.isEmpty {
                    let defaultSources = Array(cachedSources.prefix(NewsAPIConstants.defaultSelectedSourcesCount))
                    selectedSources = Set(defaultSources)
                }
            }
        } else {
            // No saved sources, use default count as default
            if !cachedSources.isEmpty {
                let defaultSources = Array(cachedSources.prefix(NewsAPIConstants.defaultSelectedSourcesCount))
                selectedSources = Set(defaultSources)
            }
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
            
            // Validate persisted selected sources against newly fetched sources
            let currentSelectedSources = selectedSources
            let validSelectedSources = currentSelectedSources.filter { fetchedSources.contains($0) }
            
            // Update selected sources to only include valid ones
            if validSelectedSources.count != currentSelectedSources.count {
                selectedSources = Set(validSelectedSources)
            }
            
            // Set default count of fetched sources as default selected sources only if none are selected
            let shouldLoadArticles = !fetchedSources.isEmpty && selectedSources.isEmpty
            if shouldLoadArticles {
                let defaultSources = Array(fetchedSources.prefix(NewsAPIConstants.defaultSelectedSourcesCount))
                selectedSources = Set(defaultSources)
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
                
                // Validate persisted selected sources against cached sources
                let currentSelectedSources = selectedSources
                let validSelectedSources = currentSelectedSources.filter { cachedSources.contains($0) }
                
                // Update selected sources to only include valid ones
                if validSelectedSources.count != currentSelectedSources.count {
                    selectedSources = Set(validSelectedSources)
                }
                
                // Set default count of cached sources as default selected if none are selected
                let shouldLoadArticles = selectedSources.isEmpty && !cachedSources.isEmpty
                if shouldLoadArticles {
                    let defaultSources = Array(cachedSources.prefix(NewsAPIConstants.defaultSelectedSourcesCount))
                    selectedSources = Set(defaultSources)
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
    
    // MARK: - Persistence
    
    private func saveSelectedSources() {
        let sourcesArray = Array(selectedSources)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(sourcesArray) {
            userDefaults.set(data, forKey: selectedSourcesKey)
            AppLogger.logCacheSave(key: selectedSourcesKey, itemCount: sourcesArray.count)
        } else {
            AppLogger.logCacheError(key: selectedSourcesKey, error: NSError(domain: "Cache", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode selected sources"]))
        }
    }
    
    private func loadSelectedSources() -> [Article.Source]? {
        guard let data = userDefaults.data(forKey: selectedSourcesKey) else {
            AppLogger.logCacheMiss(key: selectedSourcesKey)
            return nil
        }
        let decoder = JSONDecoder()
        guard let sources = try? decoder.decode([Article.Source].self, from: data) else {
            AppLogger.logCacheError(key: selectedSourcesKey, error: NSError(domain: "Cache", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode selected sources"]))
            return nil
        }
        AppLogger.logCacheLoad(key: selectedSourcesKey, itemCount: sources.count)
        return sources
    }
}
