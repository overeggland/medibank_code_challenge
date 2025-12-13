import Foundation
@testable import MedibankNews

final class MockNewsService: NewsServicing {
    var fetchTopHeadlinesResult: Result<[Article], Error>?
    var fetchTopHeadlinesCallCount = 0
    var lastCountry: NewsCountry?
    var lastCategory: NewsCategory?
    var lastSources: String?
    var lastPageSize: Int?
    
    var fetchSourcesResult: Result<[Article.Source], Error>?
    var fetchSourcesCallCount = 0
    var lastSourcesCountry: NewsCountry?
    
    func fetchTopHeadlines(country: NewsCountry?, category: NewsCategory?, sources: String?, pageSize: Int) async throws -> [Article] {
        fetchTopHeadlinesCallCount += 1
        lastCountry = country
        lastCategory = category
        lastSources = sources
        lastPageSize = pageSize
        
        if let result = fetchTopHeadlinesResult {
            switch result {
            case .success(let articles):
                return articles
            case .failure(let error):
                throw error
            }
        }
        
        return []
    }
    
    func fetchSources(country: NewsCountry?) async throws -> [Article.Source] {
        fetchSourcesCallCount += 1
        lastSourcesCountry = country
        
        if let result = fetchSourcesResult {
            switch result {
            case .success(let sources):
                return sources
            case .failure(let error):
                throw error
            }
        }
        
        return []
    }
    
    func loadCachedSources() -> [Article.Source] {
        return []
    }
}
