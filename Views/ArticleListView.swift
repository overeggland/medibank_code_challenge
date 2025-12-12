import SwiftUI

struct ArticleListView: View {
    @EnvironmentObject private var viewModel: NewsViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading headlines…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Couldn’t load news", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if viewModel.articles.isEmpty {
                    ContentUnavailableView("No articles yet", systemImage: "newspaper", description: Text("Try again in a moment."))
                } else {
                    List(viewModel.articles) { article in
                        ArticleRow(article: article)
                    }
                    .listStyle(.plain)
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
