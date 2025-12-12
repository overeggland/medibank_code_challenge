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
            print("Failed to save article: \(error)")
        }
    }
    
    func removeArticle(_ article: Article) {
        do {
            try service.removeArticle(article)
            loadSavedArticles()
        } catch {
            print("Failed to remove article: \(error)")
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
}
