import SwiftUI

struct SourcesListView: View {
    @EnvironmentObject private var viewModel: NewsViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.sources, id: \.self) { source in
                Button {
                    viewModel.toggleSourceSelection(source)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(source.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            if let id = source.id {
                                Text(id)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if viewModel.isSourceSelected(source) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
            .overlay {
                if viewModel.sources.isEmpty {
                    ContentUnavailableView("No sources yet", systemImage: "tray", description: Text("Refresh headlines to see sources."))
                }
            }
            .navigationTitle("Sources")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !viewModel.selectedSources.isEmpty {
                        Button("Clear") {
                            viewModel.clearSourceSelection()
                        }
                    }
                    
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
