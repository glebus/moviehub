import SwiftUI
import Observation
import DomainModels
import DomainUseCases
import Data
import Router
import MovieDetails
import MovieDetailsFavoriteButton
import FavoriteListDetails
import FavoriteListCreate
import FavoriteListPicker
import Auth
import AuthButton

struct AppNavigationDestinationModifier: ViewModifier {
    let container: AppContainer
    let router: AppRouter
    let authButtonBuilder: AuthButtonBuilder

    func body(content: Content) -> some View {
        content.navigationDestination(for: AppDestination<AppPushDestination>.self) { destination in
            switch destination.value {
            case .movieDetails(let movieId):
                MovieDetailsBuilder(
                    movieDetailsUseCase: { movieId in
                        try await container.movieRepository.details(id: movieId)
                    },
                    authButtonBuilder: authButtonBuilder,
                    favoriteButtonBuilder: MovieDetailsFavoriteButtonBuilder(
                        currentUserUseCase: { container.profileRepository.currentUser },
                        currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                        favoriteListByMovieStateUseCase: { container.favoritesRepository.favoriteListByMovie },
                        favoriteListByMovieSequenceUseCase: { container.favoritesRepository.favoriteListByMovieSequence },
                        handleFavoriteTapUseCase: { movieDetails in
                            try await container.handleMovieDetailsFavoriteTapUseCase.handleTap(movieDetails: movieDetails)
                        },
                        lookupFavoriteListUseCase: { movieId in
                            try await container.lookupFavoriteListUseCase.favoriteListId(movieId: movieId)
                        },
                        router: router
                    )
                ).build(movieId: movieId)
            case .favoriteListDetails(let listId):
                FavoriteListDetailsBuilder(
                    listId: listId,
                    currentUserUseCase: { container.profileRepository.currentUser },
                    currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                    favoriteListsStateUseCase: { container.favoriteListsRepository.lists },
                    favoriteListsSequenceUseCase: { container.favoriteListsRepository.listsSequence },
                    refreshFavoriteListsUseCase: { try await container.refreshFavoriteListsUseCase.refresh() },
                    favoritesByListStateUseCase: { container.favoritesRepository.favoritesByList },
                    favoritesByListSequenceUseCase: { container.favoritesRepository.favoritesByListSequence },
                    refreshFavoritesUseCase: { listId in
                        try await container.refreshFavoritesUseCase.refreshFavorites(listId: listId)
                    },
                    router: router,
                    authButtonBuilder: authButtonBuilder
                ).build()
            }
        }
    }
}

struct AppPresentationModifier: ViewModifier {
    let container: AppContainer
    @Bindable var router: AppRouter

    func body(content: Content) -> some View {
        content.sheet(item: $router.presentedSheet) { destination in
            switch destination.value {
            case .auth:
                AuthBuilder(
                    loginUseCase: { username in
                        try await container.loginUseCase.login(username: username)
                    },
                    router: router
                ).build()
            case .favoriteListPicker(let details):
                NavigationStack {
                    FavoriteListPickerBuilder(
                        movieDetails: details,
                        currentUserUseCase: { container.profileRepository.currentUser },
                        currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                        favoriteListsStateUseCase: { container.favoriteListsRepository.lists },
                        favoriteListsSequenceUseCase: { container.favoriteListsRepository.listsSequence },
                        refreshFavoriteListsUseCase: { try await container.refreshFavoriteListsUseCase.refresh() },
                        addFavoriteUseCase: { movie, listId in
                            try await container.addFavoriteUseCase.addFavorite(movie: movie, listId: listId)
                        },
                        router: router,
                        authButtonBuilder: AuthButtonBuilder(
                            currentUserUseCase: { container.profileRepository.currentUser },
                            currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                            router: router
                        )
                    ).build()
                }
            case .favoriteListCreate:
                FavoriteListCreateBuilder(
                    createFavoriteListUseCase: { name, color in
                        try await container.createFavoriteListUseCase.create(name: name, color: color)
                    },
                    currentUserUseCase: { container.profileRepository.currentUser },
                    router: router
                ).build()
            }
        }
    }
}

extension View {
    func appNavigationDestination(
        container: AppContainer,
        router: AppRouter,
        authButtonBuilder: AuthButtonBuilder
    ) -> some View {
        modifier(AppNavigationDestinationModifier(
            container: container,
            router: router,
            authButtonBuilder: authButtonBuilder
        ))
    }

    func appPresentation(container: AppContainer, router: AppRouter) -> some View {
        modifier(AppPresentationModifier(container: container, router: router))
    }
}
