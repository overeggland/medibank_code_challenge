import SwiftUI

struct ArticleListView: View {
    @EnvironmentObject private var viewModel: NewsViewModel
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading headlines…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Couldn't load news", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if viewModel.filteredArticles.isEmpty {
                    if viewModel.selectedSources.isEmpty {
                        ContentUnavailableView("No articles yet",
                                               systemImage: "newspaper",
                                               description: Text("Try again in a moment."))
                    } else {
                        ContentUnavailableView("No articles",
                                               systemImage: "newspaper",
                                               description: Text("No articles match the selected sources."))
                    }
                } else {
                    List(viewModel.filteredArticles) { article in
                        ArticleRow(article: article, navigationPath: $navigationPath)
                    }
                    .listStyle(.plain)
                    .navigationDestination(for: Article.self) { article in
                        ArticleDetailView(article: article)
                    }
                }
            }
            .navigationTitle("Top Headlines")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.loadTopHeadlines() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .task {
            await viewModel.loadTopHeadlines()
        }
    }
}

struct ArticleListView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleListView()
            .environmentObject(NewsViewModel(service: NewsService()))
            .environmentObject(SavedArticlesViewModel(service: SavedArticlesService()))
    }
}
