import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @EnvironmentObject private var savedArticlesViewModel: SavedArticlesViewModel
    
    var body: some View {
        WebView(url: article.url)
            .navigationTitle(article.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            savedArticlesViewModel.toggleSaveArticle(article)
                        } label: {
                            let isSaved = savedArticlesViewModel.isArticleSaved(article)
                            Image(systemName: isSaved ? "heart.fill" : "heart")
                                .foregroundStyle(isSaved ? .red : .primary)
                        }
                        
                        ShareLink(item: article.url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
    }
}

struct ArticleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ArticleDetailView(article: .preview)
                .environmentObject(SavedArticlesViewModel(service: SavedArticlesService()))
        }
    }
}
