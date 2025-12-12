import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    
    var body: some View {
        WebView(url: article.url)
            .navigationTitle(article.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: article.url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
    }
}

struct ArticleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ArticleDetailView(article: .preview)
        }
    }
}
