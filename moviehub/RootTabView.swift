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
import Router
import AuthButton

struct RootTabView: View {
    let container: AppContainer
    @State private var router = AppRouter()

    var body: some View {
        let authButtonBuilder = AuthButtonBuilder(
            currentUserUseCase: { container.profileRepository.currentUser },
            currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
            router: router
        )
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.homePath) {
                MovieListBuilder(
                    searchMoviesUseCase: { query in
                        try await container.movieRepository.search(query: query)
                    },
                    router: router,
                    authButtonBuilder: authButtonBuilder
                ).build()
                .appNavigationDestination(
                    container: container,
                    router: router,
                    authButtonBuilder: authButtonBuilder
                )
            }
            .tabItem {
                Label("Home", systemImage: "film")
            }
            .tag(AppTab.home)

            NavigationStack(path: $router.favoritesPath) {
                FavoriteListBuilder(
                    currentUserUseCase: { container.profileRepository.currentUser },
                    currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                    favoriteListsStateUseCase: { container.favoriteListsRepository.lists },
                    favoriteListsSequenceUseCase: { container.favoriteListsRepository.listsSequence },
                    refreshFavoriteListsUseCase: { try await container.refreshFavoriteListsUseCase.refresh() },
                    router: router,
                    authButtonBuilder: authButtonBuilder
                ).build()
                .appNavigationDestination(
                    container: container,
                    router: router,
                    authButtonBuilder: authButtonBuilder
                )
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }
            .tag(AppTab.favorites)

            NavigationStack(path: $router.profilePath) {
                ProfileBuilder(
                    currentUserUseCase: { container.profileRepository.currentUser },
                    currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                    logoutUseCase: { await container.logoutUseCase.logout() },
                    router: router,
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
                        router: router
                    )
                ).build()
                .appNavigationDestination(
                    container: container,
                    router: router,
                    authButtonBuilder: authButtonBuilder
                )
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(AppTab.profile)
        }
        .appPresentation(container: container, router: router)
    }
}
