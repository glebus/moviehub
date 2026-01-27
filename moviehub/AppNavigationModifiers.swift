import SwiftUI
import Observation
import Router
import MovieDetails
import Auth
import AuthButton

struct AppNavigationDestinationModifier: ViewModifier {
    let container: AppContainer
    let router: AppRouter
    let authButtonBuilder: AuthButtonBuilder

    func body(content: Content) -> some View {
        content.navigationDestination(for: AppDestination<AppRoute>.self) { destination in
            switch destination.value {
            case .auth:
                EmptyView()
            case .movieDetails(let movieId):
                MovieDetailsBuilder(
                    movieRepository: container.movieRepository,
                    sessionInteractor: container.sessionInteractor,
                    favoritesInteractor: container.favoritesInteractor,
                    router: router,
                    authButtonBuilder: authButtonBuilder
                ).build(movieId: movieId)
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
            case .movieDetails:
                EmptyView()
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
