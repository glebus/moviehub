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
import FavoriteListAddMovies
import FavoriteListPicker
import Auth
import AuthButton

struct AppNavigationDestinationModifier: ViewModifier {
    let container: AppContainer
    let router: AppRouter
    let authButtonBuilder: AuthButtonBuilder

    func body(content: Content) -> some View {
        content.navigationDestination(for: AppDestination<AppPushDestination>.self) { destination in
            appPushDestinationView(
                container: container,
                router: router,
                authButtonBuilder: authButtonBuilder,
                destination: destination.value
            )
        }
    }
}

struct AppPresentationModifier: ViewModifier {
    let container: AppContainer
    @Bindable var router: AppRouter

    func body(content: Content) -> some View {
        content
            .sheet(item: sheetBinding) { childRouter in
                buildPresentedRouteView(container: container, childRouter: childRouter)
            }
            .fullScreenCover(item: fullScreenBinding) { childRouter in
                buildPresentedRouteView(container: container, childRouter: childRouter)
            }
    }

    private var sheetBinding: Binding<PresentedRouteRouter?> {
        Binding(
            get: { router.presentedRoute?.style == .sheet ? router.presentedRoute : nil },
            set: { newValue in
                if newValue == nil { router.presentedRoute = nil }
            }
        )
    }

    private var fullScreenBinding: Binding<PresentedRouteRouter?> {
        Binding(
            get: { router.presentedRoute?.style == .fullScreenCover ? router.presentedRoute : nil },
            set: { newValue in
                if newValue == nil { router.presentedRoute = nil }
            }
        )
    }
}

@ViewBuilder
private func buildPresentedRouteView(
    container: AppContainer,
    childRouter: PresentedRouteRouter
) -> some View {
    let authButtonBuilder = AuthButtonBuilder(
        currentUserUseCase: { container.profileRepository.currentUser },
        currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
        router: childRouter
    )

    switch childRouter.destination {
    case .auth:
        PresentedRouteHost(router: childRouter) {
            AuthBuilder(
                loginUseCase: { username in
                    try await container.loginUseCase.login(username: username)
                },
                router: childRouter
            ).build()
        } destinationBuilder: { destination in
            appSheetPushDestinationView(
                container: container,
                destination: destination,
                childRouter: childRouter,
                authButtonBuilder: authButtonBuilder
            )
        }
    case .favoriteListPicker(let details):
        PresentedRouteHost(router: childRouter) {
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
                router: childRouter,
                authButtonBuilder: authButtonBuilder
            ).build()
        } destinationBuilder: { destination in
            appSheetPushDestinationView(
                container: container,
                destination: destination,
                childRouter: childRouter,
                authButtonBuilder: authButtonBuilder
            )
        }
    case .favoriteListCreate:
        PresentedRouteHost(router: childRouter) {
            FavoriteListCreateBuilder(
                createFavoriteListUseCase: { name, color in
                    try await container.createFavoriteListUseCase.create(name: name, color: color)
                },
                currentUserUseCase: { container.profileRepository.currentUser },
                router: childRouter
            ).build()
        } destinationBuilder: { destination in
            appSheetPushDestinationView(
                container: container,
                destination: destination,
                childRouter: childRouter,
                authButtonBuilder: authButtonBuilder
            )
        }
    }
}

@ViewBuilder
private func appSheetPushDestinationView(
    container: AppContainer,
    destination: AppPushDestination,
    childRouter: AppRouterProtocol,
    authButtonBuilder: AuthButtonBuilder
) -> some View {
    switch destination {
    case .favoriteListAddMovies(let request):
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
            router: childRouter,
        ).build()
    case .movieDetails, .favoriteListDetails:
        appPushDestinationView(
            container: container,
            router: childRouter,
            authButtonBuilder: authButtonBuilder,
            destination: destination
        )
    }
}

@ViewBuilder
private func appPushDestinationView(
    container: AppContainer,
    router: AppRouterProtocol,
    authButtonBuilder: AuthButtonBuilder,
    destination: AppPushDestination
) -> some View {
    switch destination {
    case .movieDetails(let movieId):
        MovieDetailsBuilder(
            movieDetailsUseCase: { movieId in
                try await container.movieRepository.details(id: movieId)
            },
            authButtonBuilder: authButtonBuilder,
            favoriteButtonBuilder: MovieDetailsFavoriteButtonBuilder(
                currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                handleFavoriteTapUseCase: { movieDetails in
                    try await container.handleMovieDetailsFavoriteTapUseCase.handleTap(movieDetails: movieDetails)
                },
                lookupCurrentUserFavoriteListsUseCase: { movieId in
                    try await container.lookupCurrentUserFavoriteListsUseCase.favoriteListIds(movieId: movieId)
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
            refreshFavoritesUseCase: { listId in
                try await container.refreshFavoritesUseCase.refreshFavorites(listId: listId)
            },
            router: router,
            authButtonBuilder: authButtonBuilder
        ).build()
    case .favoriteListAddMovies:
        EmptyView()
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
