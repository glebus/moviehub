import SwiftUI
import Domain
import MovieList
import MovieDetails
import FavoriteList
import Profile
import Auth
import Router

struct RootTabView: View {
    let container: AppContainer
    @State private var router = AppRouter()

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.homePath) {
                MovieListBuilder(
                    movieRepository: container.movieRepository,
                    sessionInteractor: container.sessionInteractor,
                    router: router
                ).build()
                .appNavigationDestination(container: container, router: router)
            }
            .tabItem {
                Label("Home", systemImage: "film")
            }
            .tag(AppTab.home)

            NavigationStack(path: $router.favoritesPath) {
                FavoriteListBuilder(
                    sessionInteractor: container.sessionInteractor,
                    favoritesInteractor: container.favoritesInteractor,
                    router: router
                ).build()
                .appNavigationDestination(container: container, router: router)
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }
            .tag(AppTab.favorites)

            NavigationStack(path: $router.profilePath) {
                ProfileBuilder(
                    sessionInteractor: container.sessionInteractor,
                    router: router
                ).build()
                .appNavigationDestination(container: container, router: router)
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(AppTab.profile)
        }
        .appPresentation(container: container, router: router)
    }
}
