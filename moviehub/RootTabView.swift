import SwiftUI
import DomainModels
import DomainUseCases
import Data
import MovieList
import MovieDetails
import FavoriteList
import FavoriteListsManage
import Profile
import Auth
import Coordinator
import AuthButton

struct RootTabView: View {
    let container: AppContainer
    @State private var coordinator = AppCoordinator()

    var body: some View {
        let authButtonBuilder = AuthButtonBuilder(
            currentUserUseCase: { container.profileRepository.currentUser },
            currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
            coordinator: coordinator
        )
        TabView(selection: $coordinator.selectedTab) {
            NavigationStack(path: $coordinator.homePath) {
                MovieListBuilder(
                    searchMoviesUseCase: { query in
                        try await container.movieRepository.search(query: query)
                    },
                    coordinator: coordinator,
                    authButtonBuilder: authButtonBuilder
                ).build()
                .appCoordinatorDestination(
                    container: container,
                    coordinator: coordinator,
                    authButtonBuilder: authButtonBuilder
                )
            }
            .tabItem {
                Label("Home", systemImage: "film")
            }
            .tag(AppTab.home)

            NavigationStack(path: $coordinator.favoritesPath) {
                FavoriteListBuilder(
                    currentUserUseCase: { container.profileRepository.currentUser },
                    currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                    favoriteListsStateUseCase: { container.favoriteListsRepository.lists },
                    favoriteListsSequenceUseCase: { container.favoriteListsRepository.listsSequence },
                    refreshFavoriteListsUseCase: { try await container.refreshFavoriteListsUseCase.refresh() },
                    coordinator: coordinator,
                    authButtonBuilder: authButtonBuilder
                ).build()
                .appCoordinatorDestination(
                    container: container,
                    coordinator: coordinator,
                    authButtonBuilder: authButtonBuilder
                )
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }
            .tag(AppTab.favorites)

            NavigationStack(path: $coordinator.profilePath) {
                ProfileBuilder(
                    currentUserUseCase: { container.profileRepository.currentUser },
                    currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                    logoutUseCase: { await container.logoutUseCase.logout() },
                    coordinator: coordinator,
                    authButtonBuilder: authButtonBuilder,
                    favoriteListsManageBuilder: FavoriteListsManageBuilder(
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
                ).build()
                .appCoordinatorDestination(
                    container: container,
                    coordinator: coordinator,
                    authButtonBuilder: authButtonBuilder
                )
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(AppTab.profile)
        }
        .appCoordinatorPresentation(container: container, coordinator: coordinator)
    }
}
