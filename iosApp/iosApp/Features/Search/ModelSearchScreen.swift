import SwiftUI
import Shared

struct ModelSearchScreen: View {
    @StateObject private var viewModel = ModelSearchViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.models.isEmpty {
                    ProgressView()
                } else if let error = viewModel.error, viewModel.models.isEmpty {
                    errorView(message: error)
                } else if viewModel.models.isEmpty && !viewModel.isLoading {
                    emptyView
                } else {
                    modelGrid
                }
            }
            .navigationTitle("CivitDeck")
            .searchable(
                text: $viewModel.query,
                prompt: "Search models..."
            )
            .onSubmit(of: .search) {
                viewModel.onSearch()
            }
            .refreshable {
                viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("All Types") {
                            viewModel.onTypeSelected(nil)
                        }
                        ForEach(modelTypeOptions, id: \.self) { type in
                            Button(type.name) {
                                viewModel.onTypeSelected(type)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedType?.name ?? "All Types")
                                .font(.caption)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                    }
                }
            }
        }
    }

    private var modelGrid: some View {
        ScrollView {
            typeFilterChips

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(viewModel.models.enumerated()), id: \.element.id) { index, model in
                    ModelCardView(model: model)
                        .onAppear {
                            if index == viewModel.models.count - 3 {
                                viewModel.loadMore()
                            }
                        }
                }
            }
            .padding(.horizontal, 12)

            if viewModel.isLoadingMore {
                ProgressView()
                    .padding()
            }
        }
    }

    private var typeFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(label: "All", isSelected: viewModel.selectedType == nil) {
                    viewModel.onTypeSelected(nil)
                }
                ForEach(modelTypeOptions, id: \.self) { type in
                    chipButton(label: type.name, isSelected: viewModel.selectedType == type) {
                        viewModel.onTypeSelected(type)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private func chipButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color.accentColor.opacity(0.2)
                        : Color(.systemGray5)
                )
                .foregroundColor(isSelected ? .accentColor : .primary)
                .clipShape(Capsule())
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            Button("Retry") {
                viewModel.refresh()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No models found")
                .foregroundColor(.secondary)
        }
    }
}

private let modelTypeOptions: [ModelType] = [
    .checkpoint, .lora, .loCon, .controlnet,
    .textualInversion, .hypernetwork, .upscaler, .vae,
    .poses, .wildcards, .workflows, .motionModule,
    .aestheticGradient, .other,
]
