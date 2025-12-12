import Testing
import Foundation
@testable import MedibankNews

@Suite("NewsService Tests")
struct NewsServiceTests {
    var service: NewsService {
        NewsService(apiKey: "test-key")
    }
    
    @Test("Fetch top headlines without API key returns preview data")
    func testFetchTopHeadlinesWithoutAPIKey() async throws {
        // Given - pass empty string to explicitly disable API key
        let serviceWithoutKey = NewsService(apiKey: "")
        
        // When
        let articles = try await serviceWithoutKey.fetchTopHeadlines()
        
        // Then - should return preview data
        #expect(articles == Article.previews)
    }
    
    @Test("Fetch top headlines success returns preview data when no API key")
    func testFetchTopHeadlinesSuccess() async throws {
        // Note: This test requires network mocking. To fully test this, you would need to:
        // 1. Use URLProtocol-based mocking, or
        // 2. Refactor NewsService to accept a URLSessionProtocol
        // For now, we test the offline/preview mode
        // Given - pass empty string to explicitly disable API key
        let serviceWithoutKey = NewsService(apiKey: "")
        let articles = try await serviceWithoutKey.fetchTopHeadlines()
        #expect(articles == Article.previews)
    }
    
    @Test("Fetch top headlines with country and category returns preview data when no API key")
    func testFetchTopHeadlinesWithCountryAndCategory() async throws {
        // Note: This test requires network mocking to verify URL parameters.
        // Testing URL construction logic separately would be ideal.
        // For now, we verify the method accepts parameters without error
        // Given - pass empty string to explicitly disable API key
        let serviceWithoutKey = NewsService(apiKey: "")
        let articles = try await serviceWithoutKey.fetchTopHeadlines(country: .au, category: .technology)
        #expect(articles == Article.previews) // Returns previews when no API key
    }
    
    // Note: The following tests require network mocking to properly test error cases.
    // To fully test HTTP errors, decoding errors, and network errors, you would need to:
    // 1. Use URLProtocol-based mocking with a custom URLProtocol subclass, or
    // 2. Refactor NewsService to use a protocol-based URLSession abstraction
    // 
    // Example URLProtocol-based approach:
    // - Create a MockURLProtocol that intercepts requests
    // - Configure URLSession to use MockURLProtocol
    // - Return mock responses/errors from MockURLProtocol
    //
    // For production use, consider integration tests that test against a mock server
    // or use a service like OHHTTPStubs for URLSession mocking.
    
    // MARK: - Helper Methods
    
    private func createMockResponse(articles: [Article]) throws -> Data {
        let response = TestNewsAPIResponse(
            status: "ok",
            totalResults: articles.count,
            articles: articles
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(response)
    }
}

// MARK: - Helper for creating mock responses

// Note: For full network testing, consider using URLProtocol-based mocking
// or refactoring NewsService to use a protocol-based URLSession abstraction

// MARK: - Helper for NewsAPIResponse

private struct TestNewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}
