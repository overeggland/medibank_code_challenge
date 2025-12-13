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
                } else if viewModel.selectedSources.isEmpty {
                    ContentUnavailableView("No sources selected",
                                           systemImage: "newspaper",
                                           description: Text("Please select at least one news source to view headlines."))
                } else if viewModel.filteredArticles.isEmpty {
                    ContentUnavailableView("No articles",
                                           systemImage: "newspaper",
                                           description: Text("No articles match the selected sources."))
                } else {
                    List {
                        ForEach(Array(viewModel.filteredArticles.enumerated()), id: \.element.id) { index, article in
                            ArticleRow(
                                article: article,
                                navigationPath: $navigationPath,
                                style: index % 2 == 0 ? .horizontal : .card
                            )
                        }
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
