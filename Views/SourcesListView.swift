import SwiftUI

struct SourcesListView: View {
    @EnvironmentObject private var viewModel: NewsViewModel

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
                        Task { await viewModel.loadSources() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoadingSources)
                }
            }
        }
        .task {
            if viewModel.sources.isEmpty {
                await viewModel.loadSources()
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
