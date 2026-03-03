import SwiftUI
import DomainUseCases
import Router

@MainActor
public struct FavoriteListCreateBuilder {
    private let createFavoriteListUseCase: CreateFavoriteListAction
    private let currentUserUseCase: CurrentUserReader
    private let presentedRouteRouter: PresentedRouteRouter

    public init(
        createFavoriteListUseCase: @escaping CreateFavoriteListAction,
        currentUserUseCase: @escaping CurrentUserReader,
        router: PresentedRouteRouter
    ) {
        self.createFavoriteListUseCase = createFavoriteListUseCase
        self.currentUserUseCase = currentUserUseCase
        self.presentedRouteRouter = router
    }

    public func build() -> some View {
        let coordinator = FavoriteListCreateCoordinator(presentedRouteRouter: presentedRouteRouter)
        let viewModel = FavoriteListCreateViewModel(
            createFavoriteListUseCase: createFavoriteListUseCase,
            currentUserUseCase: currentUserUseCase,
            coordinator: coordinator
        )
        return FavoriteListCreateCoordinatorView(
            viewModel: viewModel,
            coordinator: coordinator
        )
    }
}
