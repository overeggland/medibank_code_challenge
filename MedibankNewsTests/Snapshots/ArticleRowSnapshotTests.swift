import XCTest
import SwiftUI
@testable import MedibankNews
import SnapshotTesting

@MainActor
final class ArticleRowSnapshotTests: XCTestCase {
    
    var savedArticlesViewModel: SavedArticlesViewModel!
    
    override func setUp() {
        super.setUp()
        savedArticlesViewModel = SavedArticlesViewModel(service: SavedArticlesService())
    }
    
    override func tearDown() {
        savedArticlesViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Horizontal Style Tests
    
    func testArticleRowHorizontalStyle() {
        let view = ArticleRow(
            article: .preview,
            navigationPath: .constant(NavigationPath()),
            style: .horizontal
        )
        .environmentObject(savedArticlesViewModel)
        .frame(width: 375, height: 120)
        .padding()
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testArticleRowHorizontalStyleWithoutImage() {
        let article = Article(
            title: "Article Without Image",
            author: "Test Author",
            description: "This article has no image thumbnail.",
            url: URL(string: "https://example.com/no-image")!,
            urlToImage: nil,
            publishedAt: Date(),
            content: nil,
            source: Article.Source(id: nil, name: "Test Source")
        )
        
        let view = ArticleRow(
            article: article,
            navigationPath: .constant(NavigationPath()),
            style: .horizontal
        )
        .environmentObject(savedArticlesViewModel)
        .frame(width: 375, height: 120)
        .padding()
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Card Style Tests
    
    func testArticleRowCardStyle() {
        let view = ArticleRow(
            article: .preview,
            navigationPath: .constant(NavigationPath()),
            style: .card
        )
        .environmentObject(savedArticlesViewModel)
        .frame(width: 375, height: 350)
        .padding()
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testArticleRowCardStyleWithoutImage() {
        let article = Article(
            title: "Card Style Article Without Image",
            author: "Test Author",
            description: "This card style article has no image thumbnail.",
            url: URL(string: "https://example.com/card-no-image")!,
            urlToImage: nil,
            publishedAt: Date(),
            content: nil,
            source: Article.Source(id: nil, name: "Test Source")
        )
        
        let view = ArticleRow(
            article: article,
            navigationPath: .constant(NavigationPath()),
            style: .card
        )
        .environmentObject(savedArticlesViewModel)
        .frame(width: 375, height: 250)
        .padding()
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Compact Style Tests
    
    func testArticleRowCompactStyle() {
        let view = ArticleRow(
            article: .preview,
            navigationPath: .constant(NavigationPath()),
            style: .compact
        )
        .environmentObject(savedArticlesViewModel)
        .frame(width: 375, height: 100)
        .padding()
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testArticleRowCompactStyleLongTitle() {
        let article = Article(
            title: "This is a very long article title that should wrap to multiple lines and test how the compact style handles longer text content",
            author: "Test Author",
            description: "Description text",
            url: URL(string: "https://example.com/long-title")!,
            urlToImage: nil,
            publishedAt: Date(),
            content: nil,
            source: Article.Source(id: "long", name: "Long Title Source")
        )
        
        let view = ArticleRow(
            article: article,
            navigationPath: .constant(NavigationPath()),
            style: .compact
        )
        .environmentObject(savedArticlesViewModel)
        .frame(width: 375, height: 120)
        .padding()
        
        assertSnapshot(matching: view, as: .image)
    }
    
    // MARK: - Saved State Tests
    
    func testArticleRowHorizontalStyleSaved() {
        // Save the article first
        savedArticlesViewModel.saveArticle(.preview)
        
        let view = ArticleRow(
            article: .preview,
            navigationPath: .constant(NavigationPath()),
            style: .horizontal
        )
        .environmentObject(savedArticlesViewModel)
        .frame(width: 375, height: 120)
        .padding()
        
        assertSnapshot(matching: view, as: .image)
    }
    
    func testArticleRowCardStyleSaved() {
        // Save the article first
        savedArticlesViewModel.saveArticle(.preview)
        
        let view = ArticleRow(
            article: .preview,
            navigationPath: .constant(NavigationPath()),
            style: .card
        )
        .environmentObject(savedArticlesViewModel)
        .frame(width: 375, height: 350)
        .padding()
        
        assertSnapshot(matching: view, as: .image)
    }
}

