import SwiftUI

@main
struct MedibankNewsApp: App {
    @StateObject private var newsViewModel = NewsViewModel(service: NewsService())
    @StateObject private var savedArticlesViewModel = SavedArticlesViewModel(service: SavedArticlesService())

    var body: some Scene {
        WindowGroup {
            TabView {
                ArticleListView()
                    .tabItem {
                        Label("Headlines", systemImage: "newspaper")
                    }
                    .accessibilityIdentifier("headlines_tab")

                SourcesListView()
                    .tabItem {
                        Label("Sources", systemImage: "list.bullet.rectangle")
                    }
                    .accessibilityIdentifier("sources_tab")
                
                SavedArticlesListView()
                    .tabItem {
                        Label("Saved", systemImage: "heart.fill")
                    }
                    .accessibilityIdentifier("saved_tab")
            }
            .environmentObject(newsViewModel)
            .environmentObject(savedArticlesViewModel)
        }
    }
}
