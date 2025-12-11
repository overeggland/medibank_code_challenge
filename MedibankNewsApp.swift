import SwiftUI

@main
struct MedibankNewsApp: App {
    @StateObject private var newsViewModel = NewsViewModel(service: NewsService())

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
            }
            .environmentObject(newsViewModel)
        }
    }
}
