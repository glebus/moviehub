import SwiftUI
import DomainModels
import DomainUseCases
import Router

@MainActor
public struct FavoriteListCreateBuilder {
    private let createFavoriteListUseCase: CreateFavoriteListAction
    private let currentUserUseCase: CurrentUserReader
    private let router: AppRouterProtocol

    public init(
        createFavoriteListUseCase: @escaping CreateFavoriteListAction,
        currentUserUseCase: @escaping CurrentUserReader,
        router: AppRouterProtocol
    ) {
        self.createFavoriteListUseCase = createFavoriteListUseCase
        self.currentUserUseCase = currentUserUseCase
        self.router = router
    }

    public func build() -> some View {
        let viewModel = FavoriteListCreateViewModel(
            createFavoriteListUseCase: createFavoriteListUseCase,
            currentUserUseCase: currentUserUseCase,
            router: router
        )
        return FavoriteListCreateCoordinator(viewModel: viewModel)
    }
}
