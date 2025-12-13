import Foundation

@MainActor
final class SavedArticlesViewModel: ObservableObject {
    @Published private(set) var savedArticles: [Article] = []
    
    private let service: SavedArticlesServicing
    private var hasLoggedInitialLoad = false
    
    init(service: SavedArticlesServicing) {
        self.service = service
        loadSavedArticles()
    }
    
    func loadSavedArticles() {
        let loadedArticles = service.getAllSavedArticles()
        // Only log on initial load, not after every save/remove (those operations already log)
        if !hasLoggedInitialLoad && !loadedArticles.isEmpty {
            AppLogger.logCacheLoad(key: "savedArticles", itemCount: loadedArticles.count)
            hasLoggedInitialLoad = true
        }
        savedArticles = loadedArticles
    }
    
    func saveArticle(_ article: Article) {
        do {
            try service.saveArticle(article)
            loadSavedArticles()
        } catch {
            AppLogger.logError("Failed to save article", error: error)
        }
    }
    
    func removeArticle(_ article: Article) {
        do {
            try service.removeArticle(article)
            loadSavedArticles()
        } catch {
            AppLogger.logError("Failed to remove article", error: error)
        }
    }
    
    func isArticleSaved(_ article: Article) -> Bool {
        // Use cached savedArticles instead of calling service to avoid excessive logging
        savedArticles.contains(where: { $0.id == article.id })
    }
    
    func toggleSaveArticle(_ article: Article) {
        if isArticleSaved(article) {
            removeArticle(article)
        } else {
            saveArticle(article)
        }
    }
    
    func clearAllArticles() {
        // Get a snapshot of all articles before clearing to avoid iteration issues
        let articlesToRemove = savedArticles
        for article in articlesToRemove {
            do {
                try service.removeArticle(article)
            } catch {
                AppLogger.logError("Failed to remove article", error: error)
            }
        }
        loadSavedArticles()
    }
}
