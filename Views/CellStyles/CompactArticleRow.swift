import SwiftUI

struct CompactArticleRow: View {
    let article: Article
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject private var savedArticlesViewModel: SavedArticlesViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                navigationPath.append(article)
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(article.source.name.uppercased())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(article.publishedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(article.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("article_row_\(article.shortID)")
            
            Button {
                savedArticlesViewModel.toggleSaveArticle(article)
            } label: {
                let isSaved = savedArticlesViewModel.isArticleSaved(article)
                Image(systemName: isSaved ? "heart.fill" : "heart")
                    .foregroundStyle(isSaved ? .red : .secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
            .accessibilityIdentifier("save_btn_\(article.shortID)")
        }
    }
}

struct CompactArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        CompactArticleRow(
            article: .preview,
            navigationPath: .constant(NavigationPath())
        )
        .environmentObject(SavedArticlesViewModel(service: SavedArticlesService()))
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

