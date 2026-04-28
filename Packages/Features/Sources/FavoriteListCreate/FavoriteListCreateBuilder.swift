import SwiftUI
import DomainUseCases
import Coordinator

@MainActor
public struct FavoriteListCreateBuilder {
    private let createFavoriteListUseCase: CreateFavoriteListAction
    private let currentUserUseCase: CurrentUserReader
    private let coordinator: any CoordinatorProtocol

    public init(
        createFavoriteListUseCase: @escaping CreateFavoriteListAction,
        currentUserUseCase: @escaping CurrentUserReader,
        coordinator: any CoordinatorProtocol
    ) {
        self.createFavoriteListUseCase = createFavoriteListUseCase
        self.currentUserUseCase = currentUserUseCase
        self.coordinator = coordinator
    }

    public func build() -> some View {
        let coordinator = FavoriteListCreateCoordinator(coordinator: coordinator)
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
