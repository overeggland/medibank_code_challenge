import Foundation

protocol SavedArticlesServicing {
    func saveArticle(_ article: Article) throws
    func removeArticle(_ article: Article) throws
    func isArticleSaved(_ article: Article) -> Bool
    func getAllSavedArticles() -> [Article]
}

final class SavedArticlesService: SavedArticlesServicing {
    private let userDefaults: UserDefaults
    private let savedArticlesKey = "savedArticles"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveArticle(_ article: Article) throws {
        var savedArticles = getAllSavedArticles()
        
        // Check if article is already saved
        if !savedArticles.contains(where: { $0.id == article.id }) {
            savedArticles.append(article)
            try saveArticles(savedArticles)
        }
    }
    
    func removeArticle(_ article: Article) throws {
        var savedArticles = getAllSavedArticles()
        savedArticles.removeAll { $0.id == article.id }
        try saveArticles(savedArticles)
    }
    
    func isArticleSaved(_ article: Article) -> Bool {
        let savedArticles = getAllSavedArticles()
        return savedArticles.contains(where: { $0.id == article.id })
    }
    
    func getAllSavedArticles() -> [Article] {
        guard let data = userDefaults.data(forKey: savedArticlesKey),
              let articles = try? JSONDecoder().decode([Article].self, from: data) else {
            return []
        }
        return articles
    }
    
    private func saveArticles(_ articles: [Article]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(articles)
        userDefaults.set(data, forKey: savedArticlesKey)
    }
}
