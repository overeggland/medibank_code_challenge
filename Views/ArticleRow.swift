import SwiftUI

struct ArticleRow: View {
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
            
            Button {
                savedArticlesViewModel.toggleSaveArticle(article)
            } label: {
                Image(systemName: savedArticlesViewModel.isArticleSaved(article) ? "heart.fill" : "heart")
                    .foregroundStyle(savedArticlesViewModel.isArticleSaved(article) ? .red : .secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
    }
}

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRow(article: .preview, navigationPath: .constant(NavigationPath()))
            .environmentObject(SavedArticlesViewModel(service: SavedArticlesService()))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
