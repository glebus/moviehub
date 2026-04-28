import SwiftUI
import DomainModels
import DomainUseCases
import Coordinator
import AuthButton

@MainActor
public struct FavoriteListPickerBuilder {
    private let movieDetails: MovieDetails
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let refreshFavoriteListsUseCase: RefreshFavoriteListsAction
    private let addFavoriteUseCase: AddFavoriteAction
    private let coordinator: any CoordinatorProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        movieDetails: MovieDetails,
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        refreshFavoriteListsUseCase: @escaping RefreshFavoriteListsAction,
        addFavoriteUseCase: @escaping AddFavoriteAction,
        coordinator: any CoordinatorProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieDetails = movieDetails
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.refreshFavoriteListsUseCase = refreshFavoriteListsUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.coordinator = coordinator
        self.authButtonBuilder = authButtonBuilder
    }

    public func build() -> some View {
        let viewModel = FavoriteListPickerViewModel(
            movieDetails: movieDetails,
            currentUserUseCase: currentUserUseCase,
            currentUserSequenceUseCase: currentUserSequenceUseCase,
            favoriteListsStateUseCase: favoriteListsStateUseCase,
            favoriteListsSequenceUseCase: favoriteListsSequenceUseCase,
            refreshFavoriteListsUseCase: refreshFavoriteListsUseCase,
            addFavoriteUseCase: addFavoriteUseCase,
            coordinator: coordinator,
            authButtonBuilder: authButtonBuilder
        )
        return FavoriteListPickerScreen(viewModel: viewModel)
    }
}
