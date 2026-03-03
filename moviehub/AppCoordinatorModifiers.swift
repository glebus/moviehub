import SwiftUI
import Observation
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
import Auth
import AuthButton

struct AppCoordinatorDestinationModifier: ViewModifier {
    let container: AppContainer
    let coordinator: AppCoordinator
    let authButtonBuilder: AuthButtonBuilder

    func body(content: Content) -> some View {
        content.navigationDestination(for: AppDestination<AppPushDestination>.self) { destination in
            appPushDestinationView(
                container: container,
                coordinator: coordinator,
                authButtonBuilder: authButtonBuilder,
                destination: destination.value
            )
        }
    }
}

struct AppCoordinatorPresentationModifier: ViewModifier {
    let container: AppContainer
    @Bindable var coordinator: AppCoordinator

    func body(content: Content) -> some View {
        content
            .sheet(item: sheetBinding) { childCoordinator in
                buildPresentationCoordinatorView(container: container, childCoordinator: childCoordinator)
            }
            .fullScreenCover(item: fullScreenBinding) { childCoordinator in
                buildPresentationCoordinatorView(container: container, childCoordinator: childCoordinator)
            }
    }

    private var sheetBinding: Binding<PresentationCoordinator?> {
        Binding(
            get: {
                coordinator.presentationCoordinator?.style == .sheet
                    ? coordinator.presentationCoordinator
                    : nil
            },
            set: { newValue in
                if newValue == nil { coordinator.presentationCoordinator = nil }
            }
        )
    }

    private var fullScreenBinding: Binding<PresentationCoordinator?> {
        Binding(
            get: {
                coordinator.presentationCoordinator?.style == .fullScreenCover
                    ? coordinator.presentationCoordinator
                    : nil
            },
            set: { newValue in
                if newValue == nil { coordinator.presentationCoordinator = nil }
            }
        )
    }
}

@ViewBuilder
private func buildPresentationCoordinatorView(
    container: AppContainer,
    childCoordinator: PresentationCoordinator
) -> some View {
    let authButtonBuilder = AuthButtonBuilder(
        currentUserUseCase: { container.profileRepository.currentUser },
        currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
        coordinator: childCoordinator
    )

    switch childCoordinator.destination {
    case .auth:
        PresentationCoordinatorHost(coordinator: childCoordinator) {
            AuthBuilder(
                loginUseCase: { username in
                    try await container.loginUseCase.login(username: username)
                },
                coordinator: childCoordinator
            ).build()
        } destinationBuilder: { destination in
            appSheetPushDestinationView(
                container: container,
                destination: destination,
                childCoordinator: childCoordinator,
                authButtonBuilder: authButtonBuilder
            )
        } presentedRouteBuilder: { nestedRouter in
            AnyView(buildPresentedRouteView(container: container, childRouter: nestedRouter))
        }
    case .favoriteListPicker(let details):
        PresentationCoordinatorHost(coordinator: childCoordinator) {
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
                coordinator: childCoordinator,
                authButtonBuilder: authButtonBuilder
            ).build()
        } destinationBuilder: { destination in
            appSheetPushDestinationView(
                container: container,
                destination: destination,
                childCoordinator: childCoordinator,
                authButtonBuilder: authButtonBuilder
            )
        } presentedRouteBuilder: { nestedRouter in
            AnyView(buildPresentedRouteView(container: container, childRouter: nestedRouter))
        }
    case .favoriteListCreate:
        PresentationCoordinatorHost(coordinator: childCoordinator) {
            FavoriteListCreateBuilder(
                createFavoriteListUseCase: { name, color in
                    try await container.createFavoriteListUseCase.create(name: name, color: color)
                },
                currentUserUseCase: { container.profileRepository.currentUser },
                coordinator: childCoordinator
            ).build()
        } destinationBuilder: { destination in
            appSheetPushDestinationView(
                container: container,
                destination: destination,
                childCoordinator: childCoordinator,
                authButtonBuilder: authButtonBuilder
            )
        } presentedRouteBuilder: { nestedRouter in
            AnyView(buildPresentedRouteView(container: container, childRouter: nestedRouter))
        }
    }
}

@ViewBuilder
private func appSheetPushDestinationView(
    container: AppContainer,
    destination: AppPushDestination,
    childCoordinator: AppCoordinatorProtocol,
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
            coordinator: childCoordinator,
        ).build()
    case .movieDetails, .favoriteListDetails:
        appPushDestinationView(
            container: container,
            coordinator: childCoordinator,
            authButtonBuilder: authButtonBuilder,
            destination: destination
        )
    }
}

@ViewBuilder
private func appPushDestinationView(
    container: AppContainer,
    coordinator: AppCoordinatorProtocol,
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
                coordinator: coordinator
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
            coordinator: coordinator,
            authButtonBuilder: authButtonBuilder
        ).build()
    case .favoriteListAddMovies:
        EmptyView()
    }
}

extension View {
    func appCoordinatorDestination(
        container: AppContainer,
        coordinator: AppCoordinator,
        authButtonBuilder: AuthButtonBuilder
    ) -> some View {
        modifier(AppCoordinatorDestinationModifier(
            container: container,
            coordinator: coordinator,
            authButtonBuilder: authButtonBuilder
        ))
    }

    func appCoordinatorPresentation(container: AppContainer, coordinator: AppCoordinator) -> some View {
        modifier(AppCoordinatorPresentationModifier(container: container, coordinator: coordinator))
    }
}
