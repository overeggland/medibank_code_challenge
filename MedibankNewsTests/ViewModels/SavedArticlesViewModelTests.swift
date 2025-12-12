import Foundation
import Testing
@testable import MedibankNews

@Suite("SavedArticlesViewModel Tests")
struct SavedArticlesViewModelTests {
    @MainActor
    func createViewModel() -> (SavedArticlesViewModel, MockSavedArticlesService) {
        let mockService = MockSavedArticlesService()
        let viewModel = SavedArticlesViewModel(service: mockService)
        return (viewModel, mockService)
    }
    
    @Test("Initial state has empty saved articles")
    @MainActor
    func testInitialState() {
        let (viewModel, _) = createViewModel()
        // Then - should load saved articles on init
        #expect(viewModel.savedArticles.isEmpty)
    }
    
    @Test("Save article adds it to saved articles")
    @MainActor
    func testSaveArticle() {
        // Given
        let (viewModel, mockService) = createViewModel()
        let article = Article.preview
        
        // When
        viewModel.saveArticle(article)
        
        // Then
        #expect(mockService.saveArticleCallCount == 1)
        #expect(viewModel.savedArticles.contains(where: { $0.id == article.id }))
        #expect(viewModel.isArticleSaved(article))
    }
    
    @Test("Remove article removes it from saved articles")
    @MainActor
    func testRemoveArticle() {
        // Given
        let (viewModel, mockService) = createViewModel()
        let article = Article.preview
        viewModel.saveArticle(article)
        #expect(viewModel.isArticleSaved(article))
        
        // When
        viewModel.removeArticle(article)
        
        // Then
        #expect(mockService.removeArticleCallCount == 1)
        #expect(!viewModel.savedArticles.contains(where: { $0.id == article.id }))
        #expect(!viewModel.isArticleSaved(article))
    }
    
    @Test("Toggle save article when not saved adds it")
    @MainActor
    func testToggleSaveArticle_WhenNotSaved() {
        // Given
        let (viewModel, mockService) = createViewModel()
        let article = Article.preview
        #expect(!viewModel.isArticleSaved(article))
        
        // When
        viewModel.toggleSaveArticle(article)
        
        // Then
        #expect(viewModel.isArticleSaved(article))
        #expect(mockService.saveArticleCallCount == 1)
        #expect(mockService.removeArticleCallCount == 0)
    }
    
    @Test("Toggle save article when saved removes it")
    @MainActor
    func testToggleSaveArticle_WhenSaved() {
        // Given
        let (viewModel, mockService) = createViewModel()
        let article = Article.preview
        viewModel.saveArticle(article)
        #expect(viewModel.isArticleSaved(article))
        
        // When
        viewModel.toggleSaveArticle(article)
        
        // Then
        #expect(!viewModel.isArticleSaved(article))
        #expect(mockService.saveArticleCallCount == 1) // Initial save
        #expect(mockService.removeArticleCallCount == 1) // Toggle remove
    }
    
    @Test("Is article saved returns correct state")
    @MainActor
    func testIsArticleSaved() {
        // Given
        let (viewModel, _) = createViewModel()
        let article = Article.preview
        
        // When/Then - initially not saved
        #expect(!viewModel.isArticleSaved(article))
        
        // When/Then - after saving
        viewModel.saveArticle(article)
        #expect(viewModel.isArticleSaved(article))
        
        // When/Then - after removing
        viewModel.removeArticle(article)
        #expect(!viewModel.isArticleSaved(article))
    }
    
    @Test("Load saved articles loads all saved articles")
    @MainActor
    func testLoadSavedArticles() {
        // Given
        let (viewModel, _) = createViewModel()
        let article1 = Article.preview
        let article2 = Article.previews[1]
        
        viewModel.saveArticle(article1)
        viewModel.saveArticle(article2)
        
        // When
        viewModel.loadSavedArticles()
        
        // Then
        #expect(viewModel.savedArticles.count == 2)
        #expect(viewModel.savedArticles.contains(where: { $0.id == article1.id }))
        #expect(viewModel.savedArticles.contains(where: { $0.id == article2.id }))
    }
    
    @Test("Save article handles error gracefully")
    @MainActor
    func testSaveArticleHandlesError() {
        // Given
        let (viewModel, mockService) = createViewModel()
        let article = Article.preview
        let error = NSError(domain: "TestError", code: 1)
        mockService.saveArticleError = error
        
        // When
        viewModel.saveArticle(article)
        
        // Then - should not crash, error is printed but not propagated
        #expect(mockService.saveArticleCallCount == 1)
        // Article should not be saved due to error
        #expect(!viewModel.isArticleSaved(article))
    }
    
    @Test("Remove article handles error gracefully")
    @MainActor
    func testRemoveArticleHandlesError() {
        // Given
        let (viewModel, mockService) = createViewModel()
        let article = Article.preview
        viewModel.saveArticle(article)
        let error = NSError(domain: "TestError", code: 1)
        mockService.removeArticleError = error
        
        // When
        viewModel.removeArticle(article)
        
        // Then - should not crash, error is printed but not propagated
        #expect(mockService.removeArticleCallCount == 1)
        // Article should still be saved due to error
        #expect(viewModel.isArticleSaved(article))
    }
    
    @Test("Save multiple articles saves all of them")
    @MainActor
    func testMultipleArticles() {
        // Given
        let (viewModel, _) = createViewModel()
        let articles = Article.previews
        
        // When
        for article in articles {
            viewModel.saveArticle(article)
        }
        
        // Then
        #expect(viewModel.savedArticles.count == articles.count)
        for article in articles {
            #expect(viewModel.isArticleSaved(article))
        }
    }
    
    @Test("Save duplicate article only appears once")
    @MainActor
    func testSaveDuplicateArticle() {
        // Given
        let (viewModel, mockService) = createViewModel()
        let article = Article.preview
        viewModel.saveArticle(article)
        
        // When - save same article again
        viewModel.saveArticle(article)
        
        // Then - should only appear once
        let count = viewModel.savedArticles.filter { $0.id == article.id }.count
        #expect(count == 1)
        #expect(mockService.saveArticleCallCount == 2)
    }
}
