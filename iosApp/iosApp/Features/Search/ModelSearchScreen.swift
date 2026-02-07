import SwiftUI
import Shared

struct ModelSearchScreen: View {
    @StateObject private var viewModel = ModelSearchViewModel()
    @FocusState private var isSearchFocused: Bool
    @State private var showHistory: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                searchHistoryDropdown
                typeFilterChips

                ZStack {
                    if viewModel.isLoading && viewModel.models.isEmpty {
                        ProgressView()
                            .transition(.opacity)
                    } else if let error = viewModel.error, viewModel.models.isEmpty {
                        errorView(message: error)
                            .transition(.opacity)
                    } else if viewModel.models.isEmpty && !viewModel.isLoading {
                        emptyView
                            .transition(.opacity)
                    } else {
                        modelGrid
                            .transition(.opacity)
                    }
                }
                .animation(MotionAnimation.standard, value: viewModel.isLoading)
                .animation(MotionAnimation.standard, value: viewModel.error == nil)
                .frame(maxHeight: .infinity)
            }
            .navigationTitle("CivitDeck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: Int64.self) { modelId in
                ModelDetailScreen(modelId: modelId)
            }
            .task { await viewModel.observeSearchHistory() }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.civitOnSurfaceVariant)
            TextField("Search models...", text: $viewModel.query)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    viewModel.onSearch()
                    showHistory = false
                }
                .onChange(of: viewModel.query) { newValue in
                    showHistory = newValue.isEmpty
                        && isSearchFocused
                        && !viewModel.searchHistory.isEmpty
                }
                .onChange(of: isSearchFocused) { focused in
                    showHistory = focused
                        && viewModel.query.isEmpty
                        && !viewModel.searchHistory.isEmpty
                }
            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                    showHistory = isSearchFocused && !viewModel.searchHistory.isEmpty
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.civitOnSurfaceVariant)
                }
            }
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.searchBar)
                .stroke(Color.civitOutlineVariant, lineWidth: 1)
        )
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    @ViewBuilder
    private var searchHistoryDropdown: some View {
        if showHistory && !viewModel.searchHistory.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.searchHistory, id: \.self) { item in
                    Button {
                        viewModel.onHistoryItemClick(item)
                        showHistory = false
                        isSearchFocused = false
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.civitOnSurfaceVariant)
                                .font(.civitBodySmall)
                            Text(item)
                                .font(.civitBodyMedium)
                                .foregroundColor(.civitOnSurface)
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                    }
                }
                Button {
                    viewModel.clearSearchHistory()
                    showHistory = false
                } label: {
                    Text("Clear history")
                        .font(.civitLabelMedium)
                        .foregroundColor(.civitPrimary)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                }
            }
            .background(Color.civitSurfaceContainerHigh)
            .cornerRadius(CornerRadius.card)
            .padding(.horizontal, Spacing.lg)
            .transition(.opacity.combined(with: .move(edge: .top)))
            .animation(MotionAnimation.standard, value: showHistory)
        }
    }

    private var modelGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.sm) {
                ForEach(Array(viewModel.models.enumerated()), id: \.element.id) { index, model in
                    NavigationLink(value: model.id) {
                        ModelCardView(model: model)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .offset(y: 20)))
                    .onAppear {
                        if index == viewModel.models.count - 3 {
                            viewModel.loadMore()
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)

            if viewModel.isLoadingMore {
                ProgressView()
                    .transition(.opacity)
                    .padding()
            }
        }
        .animation(MotionAnimation.standard, value: viewModel.isLoadingMore)
        .refreshable {
            viewModel.refresh()
        }
    }

    private var typeFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                chipButton(label: "All", isSelected: viewModel.selectedType == nil) {
                    viewModel.onTypeSelected(nil)
                }
                ForEach(modelTypeOptions, id: \.self) { type in
                    chipButton(label: type.name, isSelected: viewModel.selectedType == type) {
                        viewModel.onTypeSelected(type)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
        }
    }

    private func chipButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.civitLabelMedium)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color.civitPrimary.opacity(0.2)
                        : Color.civitSurfaceVariant
                )
                .foregroundColor(isSelected ? .civitPrimary : .civitOnSurface)
                .clipShape(Capsule())
                .animation(MotionAnimation.spring, value: isSelected)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: Spacing.lg) {
            Text(message)
                .foregroundColor(.civitError)
                .multilineTextAlignment(.center)
            Button("Retry") {
                viewModel.refresh()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.civitOnSurfaceVariant)
            Text("No models found")
                .foregroundColor(.civitOnSurfaceVariant)
        }
    }
}

private let modelTypeOptions: [ModelType] = [
    .checkpoint, .lora, .loCon, .controlnet,
    .textualInversion, .hypernetwork, .upscaler, .vae,
    .poses, .wildcards, .workflows, .motionModule,
    .aestheticGradient, .other,
]
