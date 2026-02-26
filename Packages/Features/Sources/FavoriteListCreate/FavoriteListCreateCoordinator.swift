import SwiftUI
import DomainModels
import Router

@MainActor
public final class FavoriteListCreateCoordinator {
    enum Destination: Hashable, Sendable {
        case color
        case created(FavoriteList)
    }

    private let presentedSheetRouter: PresentedSheetRouter

    public init(presentedSheetRouter: PresentedSheetRouter) {
        self.presentedSheetRouter = presentedSheetRouter
    }

    func showColor() {
        presentedSheetRouter.appendPathValue(Destination.color)
    }

    func showCreated(_ list: FavoriteList) {
        presentedSheetRouter.appendPathValue(Destination.created(list))
    }

    func dismiss() {
        presentedSheetRouter.dismissSheet()
    }

    func showAddMovies(for list: FavoriteList) {
        presentedSheetRouter.push(.favoriteListAddMovies(FavoriteListAddMoviesRequest(
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
