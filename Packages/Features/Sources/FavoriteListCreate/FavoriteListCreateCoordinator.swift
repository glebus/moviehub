import SwiftUI
import DomainModels
import Coordinator

enum FavoriteListCreateDestination: Hashable, Sendable {
    case color
    case created(FavoriteList)
}

@MainActor
public final class FavoriteListCreateCoordinator {
    private let coordinator: any CoordinatorProtocol

    public init(coordinator: any CoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func showColor() {
        coordinator.push(FavoriteListCreateDestination.color)
    }

    func showCreated(_ list: FavoriteList) {
        coordinator.push(FavoriteListCreateDestination.created(list))
    }

    func dismiss() {
        coordinator.dismiss()
    }

    func showAddMovies(for list: FavoriteList) {
        coordinator.push(AppDestination.favoriteListAddMovies(FavoriteListAddMoviesRequest(
            listId: list.id,
            listName: list.name,
            initialQuery: "SpiderMan"
        )))
    }
}

struct FavoriteListCreateCoordinatorView: View {
    @Bindable var viewModel: FavoriteListCreateViewModel
    let coordinator: FavoriteListCreateCoordinator

    public var body: some View {
        FavoriteListNameScreen(viewModel: viewModel)
            .navigationDestination(for: FavoriteListCreateDestination.self) { destination in
                switch destination {
                case .color:
                    FavoriteListColorScreen(viewModel: viewModel)
                case .created(let list):
                    FavoriteListCreatedScreen(viewModel: viewModel, list: list)
                }
            }
    }
}
