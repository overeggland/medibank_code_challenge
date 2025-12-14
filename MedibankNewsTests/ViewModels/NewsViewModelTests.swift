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
