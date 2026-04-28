import SwiftUI
import DomainModels
import DomainUseCases
import Data
import Coordinator
import MovieDetails
import MovieDetailsFavoriteButton
import FavoriteListDetails
import FavoriteListCreate
import FavoriteListAddMovies
import FavoriteListPicker
import FavoriteListsManage
import Auth
import AuthButton

@MainActor
func makeCoordinatorBuilder(container: AppContainer) -> CoordinatorBuilder {
    { destination, coordinator in
        switch destination {
        case .movieDetails(let movieId):
            AnyView(makeMovieDetailsView(
                movieId: movieId,
                container: container,
                coordinator: coordinator
            ))
        case .favoriteListDetails(let listId):
            AnyView(makeFavoriteListDetailsView(
                listId: listId,
                container: container,
                coordinator: coordinator
            ))
        case .favoriteListAddMovies(let request):
            AnyView(makeFavoriteListAddMoviesView(
                request: request,
                container: container,
                coordinator: coordinator
            ))
        case .auth:
            AnyView(AuthBuilder(
                loginUseCase: { username in
                    try await container.loginUseCase.login(username: username)
                },
                coordinator: coordinator
            ).build())
        case .favoriteListPicker(let details):
            AnyView(FavoriteListPickerBuilder(
                movieDetails: details,
                currentUserUseCase: { container.profileRepository.currentUser },
                currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                favoriteListsStateUseCase: { container.favoriteListsRepository.lists },
                favoriteListsSequenceUseCase: { container.favoriteListsRepository.listsSequence },
                refreshFavoriteListsUseCase: { try await container.refreshFavoriteListsUseCase.refresh() },
                addFavoriteUseCase: { movie, listId in
                    try await container.addFavoriteUseCase.addFavorite(movie: movie, listId: listId)
                },
                coordinator: coordinator,
                authButtonBuilder: makeAuthButtonBuilder(container: container, coordinator: coordinator)
            ).build())
        case .favoriteListCreate:
            AnyView(FavoriteListCreateBuilder(
                createFavoriteListUseCase: { name, color in
                    try await container.createFavoriteListUseCase.create(name: name, color: color)
                },
                currentUserUseCase: { container.profileRepository.currentUser },
                coordinator: coordinator
            ).build())
        }
    }
}

@MainActor
func makeAuthButtonBuilder(
    container: AppContainer,
    coordinator: any CoordinatorProtocol
) -> AuthButtonBuilder {
    AuthButtonBuilder(
        currentUserUseCase: { container.profileRepository.currentUser },
        currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
        coordinator: coordinator
    )
}

@MainActor
func makeFavoriteListsManageBuilder(
    container: AppContainer,
    coordinator: any CoordinatorProtocol
) -> FavoriteListsManageBuilder {
    FavoriteListsManageBuilder(
        currentUserUseCase: { container.profileRepository.currentUser },
        currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
        favoriteListsStateUseCase: { container.favoriteListsRepository.lists },
        favoriteListsSequenceUseCase: { container.favoriteListsRepository.listsSequence },
        refreshFavoriteListsUseCase: { try await container.refreshFavoriteListsUseCase.refresh() },
        renameFavoriteListUseCase: { listId, name in
            try await container.renameFavoriteListUseCase.rename(listId: listId, name: name)
        },
        deleteFavoriteListUseCase: { listId in
            try await container.deleteFavoriteListUseCase.delete(listId: listId)
        },
        coordinator: coordinator
    )
}

@MainActor
private func makeMovieDetailsView(
    movieId: MovieID,
    container: AppContainer,
    coordinator: any CoordinatorProtocol
) -> some View {
    MovieDetailsBuilder(
        movieDetailsUseCase: { movieId in
            try await container.movieRepository.details(id: movieId)
        },
        authButtonBuilder: makeAuthButtonBuilder(container: container, coordinator: coordinator),
        favoriteButtonBuilder: MovieDetailsFavoriteButtonBuilder(
            currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
            handleFavoriteTapUseCase: { movieDetails in
                try await container.handleMovieDetailsFavoriteTapUseCase.handleTap(movieDetails: movieDetails)
            },
            lookupCurrentUserFavoriteListsUseCase: { movieId in
                try await container.lookupCurrentUserFavoriteListsUseCase.favoriteListIds(movieId: movieId)
            },
            coordinator: coordinator
        )
    ).build(movieId: movieId)
}

@MainActor
private func makeFavoriteListDetailsView(
    listId: FavoriteListID,
    container: AppContainer,
    coordinator: any CoordinatorProtocol
) -> some View {
    FavoriteListDetailsBuilder(
        listId: listId,
        currentUserUseCase: { container.profileRepository.currentUser },
        currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
        favoriteListsStateUseCase: { container.favoriteListsRepository.lists },
        favoriteListsSequenceUseCase: { container.favoriteListsRepository.listsSequence },
        refreshFavoriteListsUseCase: { try await container.refreshFavoriteListsUseCase.refresh() },
        refreshFavoritesUseCase: { listId in
            try await container.refreshFavoritesUseCase.refreshFavorites(listId: listId)
        },
        coordinator: coordinator,
        authButtonBuilder: makeAuthButtonBuilder(container: container, coordinator: coordinator)
    ).build()
}

@MainActor
private func makeFavoriteListAddMoviesView(
    request: FavoriteListAddMoviesRequest,
    container: AppContainer,
    coordinator: any CoordinatorProtocol
) -> some View {
    FavoriteListAddMoviesBuilder(
        request: request,
        searchMoviesUseCase: { query in
            try await container.movieRepository.search(query: query)
        },
        movieDetailsUseCase: { movieId in
            try await container.movieRepository.details(id: movieId)
        },
        refreshFavoritesUseCase: { listId in
            try await container.refreshFavoritesUseCase.refreshFavorites(listId: listId)
        },
        addFavoriteUseCase: { movie, listId in
            try await container.addFavoriteUseCase.addFavorite(movie: movie, listId: listId)
        },
        removeFavoriteFromListUseCase: { movieId, listId in
            try await container.removeFavoriteFromListUseCase.removeFavorite(movieId: movieId, listId: listId)
        },
        coordinator: coordinator
    ).build()
}
