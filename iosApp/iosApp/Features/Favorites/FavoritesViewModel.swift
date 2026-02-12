import Foundation
import Shared

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoriteModelSummary] = []

    private let observeFavoritesUseCase: ObserveFavoritesUseCase
    private var observeTask: Task<Void, Never>?

    init() {
        self.observeFavoritesUseCase = KoinHelper.shared.getObserveFavoritesUseCase()
        observeTask = Task { await observe() }
    }

    deinit {
        observeTask?.cancel()
    }

    private func observe() async {
        for await list in observeFavoritesUseCase.invoke() {
            let items = list.compactMap { $0 as? FavoriteModelSummary }
            self.favorites = items
        }
    }
}
