import Foundation

struct Article: Identifiable, Codable, Hashable {
    let title: String
    let author: String?
    let description: String?
    let url: URL
    let urlToImage: URL?
    let publishedAt: Date
    let content: String?
    let source: Source

    var id: String { url.absoluteString }

    struct Source: Codable, Hashable {
        let id: String?
        let name: String
    }
}

// MARK: - Helpers for previews and offline state

extension Article {
    static let preview = Article(
        title: "SwiftUI News Template",
        author: "Demo Author",
        description: "Kickstart your news experience with a clean SwiftUI foundation.",
        url: URL(string: "https://example.com/swiftui-news")!,
        urlToImage: URL(string: "https://picsum.photos/600/400"),
        publishedAt: Date(),
        content: "Full story goes here for preview purposes.",
        source: Source(id: nil, name: "Demo Source")
    )

    static let previews: [Article] = [
        .preview,
        Article(
            title: "Reusable networking layer",
            author: "API Team",
            description: "Shows how to structure async/await based API calls.",
            url: URL(string: "https://example.com/networking")!,
            urlToImage: nil,
            publishedAt: Date().addingTimeInterval(-3600),
            content: "Details about networking patterns...",
            source: Source(id: "network", name: "Networking Times")
        ),
        Article(
            title: "Composable SwiftUI views",
            author: "UX Writer",
            description: "Demonstrates rows, lists, placeholders and empty states.",
            url: URL(string: "https://example.com/views")!,
            urlToImage: URL(string: "https://picsum.photos/500/300"),
            publishedAt: Date().addingTimeInterval(-7200),
            content: "Composable view discussion...",
            source: Source(id: "ux", name: "UX Daily")
        )
    ]
}
