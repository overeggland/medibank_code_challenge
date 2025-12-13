import Foundation

@MainActor
final class SavedArticlesViewModel: ObservableObject {
    @Published private(set) var savedArticles: [Article] = []
    
    private let service: SavedArticlesServicing
    
    init(service: SavedArticlesServicing) {
        self.service = service
        loadSavedArticles()
    }
    
    func loadSavedArticles() {
        savedArticles = service.getAllSavedArticles()
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
        service.isArticleSaved(article)
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
