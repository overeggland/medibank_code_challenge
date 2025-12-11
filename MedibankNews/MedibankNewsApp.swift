import SwiftUI

@main
struct MedibankNewsApp: App {
    @StateObject private var newsViewModel = NewsViewModel(service: NewsService())

    var body: some Scene {
        WindowGroup {
            ArticleListView()
                .environmentObject(newsViewModel)
        }
    }
}
