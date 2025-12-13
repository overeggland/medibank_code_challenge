import SwiftUI

struct ArticleRow: View {
    let article: Article
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject private var savedArticlesViewModel: SavedArticlesViewModel
    let style: ArticleRowStyle
    
    enum ArticleRowStyle {
        case horizontal
        case card
    }

    var body: some View {
        switch style {
        case .horizontal:
            horizontalStyle
        case .card:
            cardStyle
        }
    }
    
    // MARK: - Horizontal Style (Original)
    private var horizontalStyle: some View {
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
                let isSaved = savedArticlesViewModel.isArticleSaved(article)
                Image(systemName: isSaved ? "heart.fill" : "heart")
                    .foregroundStyle(isSaved ? .red : .secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
    }
    
    // MARK: - Card Style (Alternate)
    private var cardStyle: some View {
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

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ArticleRow(article: .preview, navigationPath: .constant(NavigationPath()), style: .horizontal)
                .environmentObject(SavedArticlesViewModel(service: SavedArticlesService()))
            
            ArticleRow(article: .preview, navigationPath: .constant(NavigationPath()), style: .card)
                .environmentObject(SavedArticlesViewModel(service: SavedArticlesService()))
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
