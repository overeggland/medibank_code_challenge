import SwiftUI

struct SavedArticlesListView: View {
    @EnvironmentObject private var savedArticlesViewModel: SavedArticlesViewModel

    var body: some View {
        NavigationStack {
            Group {
                if savedArticlesViewModel.savedArticles.isEmpty {
                    ContentUnavailableView(
                        "No saved articles",
                        systemImage: "heart.slash",
                        description: Text("Tap the heart icon on any article to save it here.")
                    )
                } else {
                    List(savedArticlesViewModel.savedArticles) { article in
                        ArticleRow(article: article)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Saved Articles")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !savedArticlesViewModel.savedArticles.isEmpty {
                        Button {
                            // Clear all saved articles
                            for article in savedArticlesViewModel.savedArticles {
                                savedArticlesViewModel.removeArticle(article)
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
        .onAppear {
            savedArticlesViewModel.loadSavedArticles()
        }
    }
}

struct SavedArticlesListView_Previews: PreviewProvider {
    static var previews: some View {
        SavedArticlesListView()
            .environmentObject(SavedArticlesViewModel(service: SavedArticlesService()))
    }
}