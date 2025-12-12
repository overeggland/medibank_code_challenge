import Foundation
import Testing
@testable import MedibankNews

@Suite("NewsViewModel Tests")
struct NewsViewModelTests {
    @MainActor
    func createViewModel() -> (NewsViewModel, MockNewsService) {
        let mockService = MockNewsService()
        let viewModel = NewsViewModel(service: mockService)
        return (viewModel, mockService)
    }
    
    @Test("Initial state has empty articles, not loading, and no error")
    @MainActor
    func testInitialState() {
        let (viewModel, _) = createViewModel()
        #expect(viewModel.articles.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Load top headlines success updates articles")
    @MainActor
    func testLoadTopHeadlinesSuccess() async {
        // Given
        let (viewModel, mockService) = createViewModel()
        let expectedArticles = Article.previews
        mockService.fetchTopHeadlinesResult = .success(expectedArticles)
        
        // When
        await viewModel.loadTopHeadlines()
        
        // Then
        #expect(viewModel.articles.count == expectedArticles.count)
        #expect(viewModel.articles == expectedArticles)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.fetchTopHeadlinesCallCount == 1)
    }
    
    @Test("Load top headlines failure sets error message")
    @MainActor
    func testLoadTopHeadlinesFailure() async {
        // Given
        let (viewModel, mockService) = createViewModel()
        let error = NewsAPIError.invalidResponse
        mockService.fetchTopHeadlinesResult = .failure(error)
        
        // When
        await viewModel.loadTopHeadlines()
        
        // Then
        #expect(viewModel.articles.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage != nil)
        #expect(mockService.fetchTopHeadlinesCallCount == 1)
    }
    
    @Test("Load top headlines with parameters passes them to service")
    @MainActor
    func testLoadTopHeadlinesWithParameters() async {
        // Given
        let (viewModel, mockService) = createViewModel()
        let country = NewsCountry.au
        let category = NewsCategory.technology
        mockService.fetchTopHeadlinesResult = .success([])
        
        // When
        await viewModel.loadTopHeadlines(country: country, category: category)
        
        // Then
        #expect(mockService.lastCountry == country)
        #expect(mockService.lastCategory == category)
    }
    
    @Test("Load top headlines prevents concurrent loads")
    @MainActor
    func testLoadTopHeadlinesPreventsConcurrentLoads() async {
        // Given
        let (viewModel, mockService) = createViewModel()
        mockService.fetchTopHeadlinesResult = .success([])
        
        // When - trigger multiple concurrent loads
        async let load1: Void = viewModel.loadTopHeadlines()
        async let load2: Void = viewModel.loadTopHeadlines()
        async let load3: Void = viewModel.loadTopHeadlines()
        
        await load1
        await load2
        await load3
        
        // Then - should only call service once due to guard !isLoading
        #expect(mockService.fetchTopHeadlinesCallCount == 1)
    }
    
    @Test("Loading state is false after fetch completes")
    @MainActor
    func testLoadingStateDuringFetch() async {
        // Given
        let (viewModel, mockService) = createViewModel()
        mockService.fetchTopHeadlinesResult = .success([])
        
        // When
        await viewModel.loadTopHeadlines()
        
        // Then - isLoading should be false after fetch
        #expect(!viewModel.isLoading)
    }
    
    @Test("Sources computed property returns unique sorted sources")
    @MainActor
    func testSourcesComputedProperty() async {
        // Given
        let (viewModel, mockService) = createViewModel()
        let article1 = Article(
            title: "Article 1",
            author: "Author 1",
            description: "Description 1",
            url: URL(string: "https://example.com/1")!,
            urlToImage: nil,
            publishedAt: Date(),
            content: nil,
            source: Article.Source(id: "source1", name: "Source B")
        )
        
        let article2 = Article(
            title: "Article 2",
            author: "Author 2",
            description: "Description 2",
            url: URL(string: "https://example.com/2")!,
            urlToImage: nil,
            publishedAt: Date(),
            content: nil,
            source: Article.Source(id: "source2", name: "Source A")
        )
        
        let article3 = Article(
            title: "Article 3",
            author: "Author 3",
            description: "Description 3",
            url: URL(string: "https://example.com/3")!,
            urlToImage: nil,
            publishedAt: Date(),
            content: nil,
            source: Article.Source(id: "source1", name: "Source B") // Duplicate source
        )
        
        mockService.fetchTopHeadlinesResult = .success([article1, article2, article3])
        
        // When
        await viewModel.loadTopHeadlines()
        
        // Then
        let sources = viewModel.sources
        #expect(sources.count == 2) // Should deduplicate
        #expect(sources[0].name == "Source A") // Should be sorted
        #expect(sources[1].name == "Source B")
    }
    
    @Test("Error is cleared on successful load")
    @MainActor
    func testErrorClearedOnSuccessfulLoad() async {
        // Given
        let (viewModel, mockService) = createViewModel()
        mockService.fetchTopHeadlinesResult = .failure(NewsAPIError.invalidResponse)
        await viewModel.loadTopHeadlines()
        #expect(viewModel.errorMessage != nil)
        
        // When
        mockService.fetchTopHeadlinesResult = .success(Article.previews)
        await viewModel.loadTopHeadlines()
        
        // Then
        #expect(viewModel.errorMessage == nil)
    }
}
