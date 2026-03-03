import SwiftUI
import DomainModels
import Coordinator

@MainActor
public final class FavoriteListCreateCoordinator {
    enum Destination: Hashable, Sendable {
        case color
        case created(FavoriteList)
    }

    private let coordinator: FlowCoordinatorProtocol

    public init(coordinator: FlowCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func showColor() {
        coordinator.appendPathValue(Destination.color)
    }

    func showCreated(_ list: FavoriteList) {
        coordinator.appendPathValue(Destination.created(list))
    }

    func dismiss() {
        coordinator.dismiss()
    }

    func showAddMovies(for list: FavoriteList) {
        coordinator.push(.favoriteListAddMovies(FavoriteListAddMoviesRequest(
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
            .navigationDestination(for: FavoriteListCreateCoordinator.Destination.self) { destination in
                switch destination {
                case .color:
                    FavoriteListColorScreen(viewModel: viewModel)
                case .created(let list):
                    FavoriteListCreatedScreen(viewModel: viewModel, list: list)
                }
            }
    }
}
