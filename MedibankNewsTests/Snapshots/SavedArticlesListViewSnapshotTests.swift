import XCTest
import SwiftUI
@testable import MedibankNews
import SnapshotTesting

@MainActor
final class SavedArticlesListViewSnapshotTests: XCTestCase {
    
    var savedArticlesViewModel: SavedArticlesViewModel!
    
    override func setUp() {
        super.setUp()
        savedArticlesViewModel = SavedArticlesViewModel(service: SavedArticlesService())
    }
    
    override func tearDown() {
        savedArticlesViewModel = nil
        super.tearDown()
    }
    
    
    func testSavedArticlesListViewWithArticles() {
        // Add some saved articles
        savedArticlesViewModel.saveArticle(.preview)
        savedArticlesViewModel.saveArticle(Article.previews[1])
        savedArticlesViewModel.saveArticle(Article.previews[2])
        
        let view = SavedArticlesListView()
            .environmentObject(savedArticlesViewModel)
            .frame(width: 375, height: 667)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testSavedArticlesListViewWithSingleArticle() {
        // Add one saved article
        savedArticlesViewModel.saveArticle(.preview)
        
        let view = SavedArticlesListView()
            .environmentObject(savedArticlesViewModel)
            .frame(width: 375, height: 667)
        
        assertSnapshot(of: view, as: .image)
    }
}

