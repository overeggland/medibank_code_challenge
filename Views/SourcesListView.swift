import SwiftUI

struct SourcesListView: View {
    @EnvironmentObject private var viewModel: NewsViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.sources, id: \.self) { source in
                VStack(alignment: .leading, spacing: 4) {
                    Text(source.name)
                        .font(.headline)
                    if let id = source.id {
                        Text(id)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
            .overlay {
                if viewModel.sources.isEmpty {
                    ContentUnavailableView("No sources yet", systemImage: "tray", description: Text("Refresh headlines to see sources."))
                }
            }
            .navigationTitle("Sources")
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
            if viewModel.articles.isEmpty {
                await viewModel.loadTopHeadlines()
            }
        }
    }
}

struct SourcesListView_Previews: PreviewProvider {
    static var previews: some View {
        SourcesListView()
            .environmentObject(NewsViewModel(service: NewsService()))
    }
}
