import SwiftUI
import Domain
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
            sessionInteractor: container.sessionInteractor,
            router: router
        )
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.homePath) {
                MovieListBuilder(
                    movieRepository: container.movieRepository,
                    sessionInteractor: container.sessionInteractor,
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
                    sessionInteractor: container.sessionInteractor,
                    favoriteListsInteractor: container.favoriteListsInteractor,
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
                    sessionInteractor: container.sessionInteractor,
                    router: router,
                    authButtonBuilder: authButtonBuilder,
                    favoriteListsManageBuilder: FavoriteListsManageBuilder(
                        sessionInteractor: container.sessionInteractor,
                        favoriteListsInteractor: container.favoriteListsInteractor,
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
