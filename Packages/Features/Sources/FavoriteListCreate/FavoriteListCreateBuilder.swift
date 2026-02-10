import SwiftUI
import Domain
import Router

@MainActor
public struct FavoriteListCreateBuilder {
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol

    public init(
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        sessionInteractor: SessionInteractorProtocol,
        router: AppRouterProtocol
    ) {
        self.favoriteListsInteractor = favoriteListsInteractor
        self.sessionInteractor = sessionInteractor
        self.router = router
    }

    public func build() -> FavoriteListCreateCoordinator {
        let viewModel = FavoriteListCreateViewModel(
            favoriteListsInteractor: favoriteListsInteractor,
            sessionInteractor: sessionInteractor,
            router: router
        )
        return FavoriteListCreateCoordinator(viewModel: viewModel)
    }
}
