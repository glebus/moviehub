import SwiftUI
import DomainModels
import DomainUseCases
import Coordinator

@MainActor
public struct FavoriteListCreateBuilder {
    private let createFavoriteListUseCase: CreateFavoriteListAction
    private let addFavoriteUseCase: AddFavoriteAction
    private let currentUserUseCase: CurrentUserReader
    private let movieToAdd: MovieDetails?
    private let coordinator: any CoordinatorProtocol

    public init(
        createFavoriteListUseCase: @escaping CreateFavoriteListAction,
        addFavoriteUseCase: @escaping AddFavoriteAction,
        currentUserUseCase: @escaping CurrentUserReader,
        movieToAdd: MovieDetails?,
        coordinator: any CoordinatorProtocol
    ) {
        self.createFavoriteListUseCase = createFavoriteListUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.currentUserUseCase = currentUserUseCase
        self.movieToAdd = movieToAdd
        self.coordinator = coordinator
    }

    public func build() -> some View {
        let coordinator = FavoriteListCreateCoordinator(coordinator: coordinator)
        let viewModel = FavoriteListCreateViewModel(
            createFavoriteListUseCase: createFavoriteListUseCase,
            addFavoriteUseCase: addFavoriteUseCase,
            currentUserUseCase: currentUserUseCase,
            movieToAdd: movieToAdd,
            coordinator: coordinator
        )
        return FavoriteListCreateCoordinatorView(
            viewModel: viewModel,
            coordinator: coordinator
        )
    }
}
