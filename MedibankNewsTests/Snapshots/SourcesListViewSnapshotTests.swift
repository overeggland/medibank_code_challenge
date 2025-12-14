import XCTest
import SwiftUI
@testable import MedibankNews
import SnapshotTesting

@MainActor
final class SourcesListViewSnapshotTests: XCTestCase {
    
    var newsViewModel: NewsViewModel!
    
    override func setUp() {
        super.setUp()
        let mockService = MockNewsService()
        newsViewModel = NewsViewModel(service: mockService)
    }
    
    override func tearDown() {
        newsViewModel = nil
        super.tearDown()
    }
    
    
    func testSourcesListViewWithSources() async {
        // Create a new view model with mock service configured
        let mockService = MockNewsService()
        let sources = [
            Article.Source(id: "source1", name: "Source One"),
            Article.Source(id: "source2", name: "Source Two"),
            Article.Source(id: "source3", name: "Source Three")
        ]
        mockService.fetchSourcesResult = .success(sources)
        
        let viewModel = NewsViewModel(service: mockService)
        
        // Load sources
        await viewModel.loadSources()
        
        // Wait a bit for state to update
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let view = SourcesListView()
            .environmentObject(viewModel)
            .frame(width: 375, height: 667)
        
        assertSnapshot(of: view, as: .image)
    }
    
}

