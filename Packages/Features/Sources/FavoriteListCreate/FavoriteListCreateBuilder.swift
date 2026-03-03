import SwiftUI
import DomainUseCases
import Coordinator

@MainActor
public struct FavoriteListCreateBuilder {
    private let createFavoriteListUseCase: CreateFavoriteListAction
    private let currentUserUseCase: CurrentUserReader
    private let flowCoordinator: FlowCoordinatorProtocol

    public init(
        createFavoriteListUseCase: @escaping CreateFavoriteListAction,
        currentUserUseCase: @escaping CurrentUserReader,
        coordinator: FlowCoordinatorProtocol
    ) {
        self.createFavoriteListUseCase = createFavoriteListUseCase
        self.currentUserUseCase = currentUserUseCase
        self.flowCoordinator = coordinator
    }

    public func build() -> some View {
        let coordinator = FavoriteListCreateCoordinator(coordinator: flowCoordinator)
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
