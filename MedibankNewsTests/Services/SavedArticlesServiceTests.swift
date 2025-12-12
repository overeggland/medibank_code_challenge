import Testing
import Foundation
@testable import MedibankNews

@Suite("SavedArticlesService Tests")
struct SavedArticlesServiceTests {
    func createService() -> (SavedArticlesService, UserDefaults, String) {
        // Use a unique suite name for each test to avoid conflicts
        let suiteName = "test.medibanknews.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Failed to create UserDefaults with suite name: \(suiteName)")
        }
        // Clear any existing data
        userDefaults.removePersistentDomain(forName: suiteName)
        let service = SavedArticlesService(userDefaults: userDefaults)
        return (service, userDefaults, suiteName)
    }
    
    func cleanup(userDefaults: UserDefaults, suiteName: String) {
        userDefaults.removePersistentDomain(forName: suiteName)
    }
    
    @Test("Save article saves it successfully")
    func testSaveArticle() throws {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        let article = Article.preview
        
        // When
        try service.saveArticle(article)
        
        // Then
        #expect(service.isArticleSaved(article))
        let savedArticles = service.getAllSavedArticles()
        #expect(savedArticles.count == 1)
        #expect(savedArticles.first?.id == article.id)
    }
    
    @Test("Save multiple articles saves all of them")
    func testSaveMultipleArticles() throws {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        let articles = Article.previews
        
        // When
        for article in articles {
            try service.saveArticle(article)
        }
        
        // Then
        let savedArticles = service.getAllSavedArticles()
        #expect(savedArticles.count == articles.count)
        for article in articles {
            #expect(service.isArticleSaved(article))
        }
    }
    
    @Test("Save duplicate article only appears once")
    func testSaveDuplicateArticle() throws {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        let article = Article.preview
        try service.saveArticle(article)
        
        // When - save same article again
        try service.saveArticle(article)
        
        // Then - should only appear once
        let savedArticles = service.getAllSavedArticles()
        let count = savedArticles.filter { $0.id == article.id }.count
        #expect(count == 1)
        #expect(savedArticles.count == 1)
    }
    
    @Test("Remove article removes it successfully")
    func testRemoveArticle() throws {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        let article = Article.preview
        try service.saveArticle(article)
        #expect(service.isArticleSaved(article))
        
        // When
        try service.removeArticle(article)
        
        // Then
        #expect(!service.isArticleSaved(article))
        let savedArticles = service.getAllSavedArticles()
        #expect(savedArticles.isEmpty)
    }
    
    @Test("Remove article not in list does not throw error")
    func testRemoveArticleNotInList() throws {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        let article = Article.preview
        // Don't save it first
        
        // When/Then - should not throw error
        try service.removeArticle(article)
        #expect(!service.isArticleSaved(article))
    }
    
    @Test("Is article saved returns correct state")
    func testIsArticleSaved() throws {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        let article = Article.preview
        
        // When/Then - initially not saved
        #expect(!service.isArticleSaved(article))
        
        // When/Then - after saving
        try service.saveArticle(article)
        #expect(service.isArticleSaved(article))
        
        // When/Then - after removing
        try service.removeArticle(article)
        #expect(!service.isArticleSaved(article))
    }
    
    @Test("Get all saved articles returns all saved articles")
    func testGetAllSavedArticles() throws {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        let articles = Article.previews
        
        // When
        for article in articles {
            try service.saveArticle(article)
        }
        
        // Then
        let savedArticles = service.getAllSavedArticles()
        #expect(savedArticles.count == articles.count)
        for article in articles {
            #expect(savedArticles.contains(where: { $0.id == article.id }))
        }
    }
    
    @Test("Get all saved articles when empty returns empty array")
    func testGetAllSavedArticlesWhenEmpty() {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        
        // When
        let savedArticles = service.getAllSavedArticles()
        
        // Then
        #expect(savedArticles.isEmpty)
    }
    
    @Test("Persistence maintains data across service instances")
    func testPersistence() throws {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        let article = Article.preview
        try service.saveArticle(article)
        
        // When - create new service instance (simulating app restart)
        let newService = SavedArticlesService(userDefaults: userDefaults)
        
        // Then - should persist data
        #expect(newService.isArticleSaved(article))
        let savedArticles = newService.getAllSavedArticles()
        #expect(savedArticles.count == 1)
        #expect(savedArticles.first?.id == article.id)
    }
    
    @Test("Remove multiple articles removes them correctly")
    func testRemoveMultipleArticles() throws {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        let articles = Article.previews
        for article in articles {
            try service.saveArticle(article)
        }
        #expect(service.getAllSavedArticles().count == articles.count)
        
        // When - remove one article
        try service.removeArticle(articles[0])
        
        // Then
        let savedArticles = service.getAllSavedArticles()
        #expect(savedArticles.count == articles.count - 1)
        #expect(!service.isArticleSaved(articles[0]))
        #expect(service.isArticleSaved(articles[1]))
    }
    
    @Test("Article encoding and decoding preserves all properties")
    func testArticleEncodingDecoding() throws {
        // Given
        let (service, userDefaults, suiteName) = createService()
        defer { cleanup(userDefaults: userDefaults, suiteName: suiteName) }
        let article = Article(
            title: "Test Article",
            author: "Test Author",
            description: "Test Description",
            url: URL(string: "https://example.com/test")!,
            urlToImage: URL(string: "https://example.com/image.jpg"),
            publishedAt: Date(),
            content: "Test Content",
            source: Article.Source(id: "test-id", name: "Test Source")
        )
        
        // When
        try service.saveArticle(article)
        let savedArticles = service.getAllSavedArticles()
        
        // Then
        #expect(savedArticles.count == 1)
        let savedArticle = savedArticles.first!
        #expect(savedArticle.title == article.title)
        #expect(savedArticle.author == article.author)
        #expect(savedArticle.description == article.description)
        #expect(savedArticle.url == article.url)
        #expect(savedArticle.urlToImage == article.urlToImage)
        #expect(savedArticle.content == article.content)
        #expect(savedArticle.source.id == article.source.id)
        #expect(savedArticle.source.name == article.source.name)
    }
}
