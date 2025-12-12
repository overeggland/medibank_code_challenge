import Foundation
@testable import MedibankNews

final class MockNewsService: NewsServicing {
    var fetchTopHeadlinesResult: Result<[Article], Error>?
    var fetchTopHeadlinesCallCount = 0
    var lastCountry: NewsCountry?
    var lastCategory: NewsCategory?
    
    func fetchTopHeadlines(country: NewsCountry, category: NewsCategory?) async throws -> [Article] {
        fetchTopHeadlinesCallCount += 1
        lastCountry = country
        lastCategory = category
        
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
}
