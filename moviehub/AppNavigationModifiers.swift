import SwiftUI
import Observation
import Router
import MovieDetails
import FavoriteList
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
                    movieRepository: container.movieRepository,
                    sessionInteractor: container.sessionInteractor,
                    favoriteListsInteractor: container.favoriteListsInteractor,
                    favoritesInteractor: container.favoritesInteractor,
                    router: router,
                    authButtonBuilder: authButtonBuilder
                ).build(movieId: movieId)
            case .favoriteListDetails(let listId):
                FavoriteListDetailsBuilder(
                    listId: listId,
                    sessionInteractor: container.sessionInteractor,
                    favoriteListsInteractor: container.favoriteListsInteractor,
                    favoritesInteractor: container.favoritesInteractor,
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
                    sessionInteractor: container.sessionInteractor,
                    router: router
                ).build()
            case .favoriteListPicker(let details):
                NavigationStack {
                    FavoriteListPickerBuilder(
                        movieDetails: details,
                        sessionInteractor: container.sessionInteractor,
                        favoriteListsInteractor: container.favoriteListsInteractor,
                        favoritesInteractor: container.favoritesInteractor,
                        router: router,
                        authButtonBuilder: AuthButtonBuilder(
                            sessionInteractor: container.sessionInteractor,
                            router: router
                        )
                    ).build()
                }
            case .favoriteListCreate:
                FavoriteListCreateBuilder(
                    favoriteListsInteractor: container.favoriteListsInteractor,
                    sessionInteractor: container.sessionInteractor,
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
