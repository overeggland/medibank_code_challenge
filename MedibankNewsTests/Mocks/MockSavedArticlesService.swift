import Foundation
@testable import MedibankNews

final class MockSavedArticlesService: SavedArticlesServicing {
    private var savedArticles: [Article] = []
    
    var saveArticleCallCount = 0
    var saveArticleError: Error?
    func saveArticle(_ article: Article) throws {
        saveArticleCallCount += 1
        if let error = saveArticleError {
            throw error
        }
        if !savedArticles.contains(where: { $0.id == article.id }) {
            savedArticles.append(article)
        }
    }
    
    var removeArticleCallCount = 0
    var removeArticleError: Error?
    func removeArticle(_ article: Article) throws {
        removeArticleCallCount += 1
        if let error = removeArticleError {
            throw error
        }
        savedArticles.removeAll { $0.id == article.id }
    }
    
    func isArticleSaved(_ article: Article) -> Bool {
        savedArticles.contains(where: { $0.id == article.id })
    }
    
    func getAllSavedArticles() -> [Article] {
        savedArticles
    }
}
