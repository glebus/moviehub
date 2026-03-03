import SwiftUI
import DomainUseCases
import Coordinator

@MainActor
public struct FavoriteListCreateBuilder {
    private let createFavoriteListUseCase: CreateFavoriteListAction
    private let currentUserUseCase: CurrentUserReader
    private let presentationCoordinator: PresentationCoordinator

    public init(
        createFavoriteListUseCase: @escaping CreateFavoriteListAction,
        currentUserUseCase: @escaping CurrentUserReader,
        coordinator: PresentationCoordinator
    ) {
        self.createFavoriteListUseCase = createFavoriteListUseCase
        self.currentUserUseCase = currentUserUseCase
        self.presentationCoordinator = coordinator
    }

    public func build() -> some View {
        let coordinator = FavoriteListCreateCoordinator(presentationCoordinator: presentationCoordinator)
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
