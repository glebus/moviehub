import SwiftUI
import DomainModels
import Coordinator

@MainActor
public final class FavoriteListCreateCoordinator {
    enum Destination: Hashable, Sendable {
        case color
        case created(FavoriteList)
    }

    private let presentationCoordinator: PresentationCoordinator

    public init(presentationCoordinator: PresentationCoordinator) {
        self.presentationCoordinator = presentationCoordinator
    }

    func showColor() {
        presentationCoordinator.appendPathValue(Destination.color)
    }

    func showCreated(_ list: FavoriteList) {
        presentationCoordinator.appendPathValue(Destination.created(list))
    }

    func dismiss() {
        presentationCoordinator.dismiss()
    }

    func showAddMovies(for list: FavoriteList) {
        presentationCoordinator.push(.favoriteListAddMovies(FavoriteListAddMoviesRequest(
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
