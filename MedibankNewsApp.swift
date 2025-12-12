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

                SourcesListView()
                    .tabItem {
                        Label("Sources", systemImage: "list.bullet.rectangle")
                    }
                
                SavedArticlesListView()
                    .tabItem {
                        Label("Saved", systemImage: "heart.fill")
                    }
            }
            .environmentObject(newsViewModel)
            .environmentObject(savedArticlesViewModel)
        }
    }
}
