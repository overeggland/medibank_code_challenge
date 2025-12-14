import SwiftUI

struct CardArticleRow: View {
    let article: Article
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject private var savedArticlesViewModel: SavedArticlesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                navigationPath.append(article)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    if let imageURL = article.urlToImage {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 180)
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
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
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
                        
                        if let description = article.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("article_row_\(article.shortID)")
            
            HStack {
                Spacer()
                Button {
                    savedArticlesViewModel.toggleSaveArticle(article)
                } label: {
                    let isSaved = savedArticlesViewModel.isArticleSaved(article)
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundStyle(isSaved ? .red : .secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.bottom, 8)
                .accessibilityIdentifier("save_btn_\(article.shortID)")
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }
    
    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
    }
}

struct CardArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        CardArticleRow(
            article: .preview,
            navigationPath: .constant(NavigationPath())
        )
        .environmentObject(SavedArticlesViewModel(service: SavedArticlesService()))
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

