import SwiftUI

struct SourcesListView: View {
    @EnvironmentObject private var viewModel: NewsViewModel
    
    private var selectedSources: [Article.Source] {
        viewModel.sources.filter { viewModel.isSourceSelected($0) }
    }
    
    private var unselectedSources: [Article.Source] {
        viewModel.sources.filter { !viewModel.isSourceSelected($0) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoadingSources {
                    ProgressView("Loading sources…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.sourcesErrorMessage {
                    ContentUnavailableView("Couldn't load sources", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if viewModel.sources.isEmpty {
                    ContentUnavailableView("No sources", systemImage: "tray", description: Text("Tap refresh to load sources."))
                } else {
                    List {
                        if !selectedSources.isEmpty {
                            Section {
                                ForEach(selectedSources, id: \.self) { source in
                                    sourceRow(for: source)
                                }
                            } header: {
                                Text("Selected Sources")
                            }
                        }
                        
                        if !unselectedSources.isEmpty {
                            Section {
                                ForEach(unselectedSources, id: \.self) { source in
                                    sourceRow(for: source)
                                }
                            } header: {
                                Text("Available Sources")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sources")
        }
        .task {
            if viewModel.sources.isEmpty {
                await viewModel.loadSources()
            }
        }
    }
    
    @ViewBuilder
    private func sourceRow(for source: Article.Source) -> some View {
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
}

struct SourcesListView_Previews: PreviewProvider {
    static var previews: some View {
        SourcesListView()
            .environmentObject(NewsViewModel(service: NewsService()))
    }
}
