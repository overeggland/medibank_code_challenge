import XCTest
import SwiftUI
@testable import MedibankNews
import SnapshotTesting

@MainActor
final class ArticleListViewSnapshotTests: XCTestCase {
    
    var newsViewModel: NewsViewModel!
    var savedArticlesViewModel: SavedArticlesViewModel!
    
    override func setUp() {
        super.setUp()
        let mockService = MockNewsService()
        newsViewModel = NewsViewModel(service: mockService)
        savedArticlesViewModel = SavedArticlesViewModel(service: SavedArticlesService())
    }
    
    override func tearDown() {
        newsViewModel = nil
        savedArticlesViewModel = nil
        super.tearDown()
    }
    
    func testArticleListViewNoSourcesSelected() {
        // Clear selected sources
        newsViewModel.selectedSources = []
        
        let view = ArticleListView()
            .environmentObject(newsViewModel)
            .environmentObject(savedArticlesViewModel)
            .frame(width: 375, height: 667)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testArticleListViewWithArticles() async {
        // Create a new view model with mock service configured
        let mockService = MockNewsService()
        mockService.fetchTopHeadlinesResult = .success(Article.previews)
        
        let viewModel = NewsViewModel(service: mockService)
        
        // Set selected sources so articles will show
        let testSource = Article.Source(id: "test", name: "Test Source")
        viewModel.selectedSources = [testSource]
        
        // Load articles
        await viewModel.loadTopHeadlines()
        
        // Wait a bit for state to update
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let view = ArticleListView()
            .environmentObject(viewModel)
            .environmentObject(savedArticlesViewModel)
            .frame(width: 375, height: 667)
        
        assertSnapshot(of: view, as: .image)
    }
}

