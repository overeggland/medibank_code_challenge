import SwiftUI

struct HorizontalArticleRow: View {
    let article: Article
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject private var savedArticlesViewModel: SavedArticlesViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                navigationPath.append(article)
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    if let imageURL = article.urlToImage {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                placeholder
                            @unknown default:
                                placeholder
                            }
                        }
                        .frame(width: 96, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(article.source.name.uppercased())
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(article.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(4)

                        if let description = article.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Text(article.publishedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
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
            .padding(.top, 6)
            .accessibilityIdentifier("save_btn_\(article.shortID)")
        }
    }
    
    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
    }
}

struct HorizontalArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalArticleRow(
            article: .preview,
            navigationPath: .constant(NavigationPath())
        )
        .environmentObject(SavedArticlesViewModel(service: SavedArticlesService()))
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

