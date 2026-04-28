import SwiftUI
import DomainUseCases
import Data
import MovieList
import FavoriteList
import Profile
import Coordinator

struct RootTabView: View {
    let container: AppContainer
    @State private var coordinator: TabCoordinator

    init(container: AppContainer) {
        self.container = container
        _coordinator = State(initialValue: TabCoordinator(
            builder: makeCoordinatorBuilder(container: container)
        ))
    }

    var body: some View {
        TabCoordinatorView(coordinator: coordinator, container: container)
    }
}

struct TabCoordinatorView: View {
    @Bindable var coordinator: TabCoordinator
    let container: AppContainer

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            NavigationStack(path: coordinator.bindingForPath(.home)) {
                let tabCoordinator = coordinator.child(for: .home)
                MovieListBuilder(
                    searchMoviesUseCase: { query in
                        try await container.movieRepository.search(query: query)
                    },
                    coordinator: tabCoordinator,
                    authButtonBuilder: makeAuthButtonBuilder(
                        container: container,
                        coordinator: tabCoordinator
                    )
                ).build()
                .navigationDestination(for: AppDestination.self) { destination in
                    coordinator.builder(destination, tabCoordinator)
                }
            }
            .tabItem {
                Label("Home", systemImage: "film")
            }
            .tag(AppTab.home)

            NavigationStack(path: coordinator.bindingForPath(.favorites)) {
                let tabCoordinator = coordinator.child(for: .favorites)
                FavoriteListBuilder(
                    currentUserUseCase: { container.profileRepository.currentUser },
                    currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                    favoriteListsStateUseCase: { container.favoriteListsRepository.lists },
                    favoriteListsSequenceUseCase: { container.favoriteListsRepository.listsSequence },
                    refreshFavoriteListsUseCase: { try await container.refreshFavoriteListsUseCase.refresh() },
                    coordinator: tabCoordinator,
                    authButtonBuilder: makeAuthButtonBuilder(
                        container: container,
                        coordinator: tabCoordinator
                    )
                ).build()
                .navigationDestination(for: AppDestination.self) { destination in
                    coordinator.builder(destination, tabCoordinator)
                }
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }
            .tag(AppTab.favorites)

            NavigationStack(path: coordinator.bindingForPath(.profile)) {
                let tabCoordinator = coordinator.child(for: .profile)
                ProfileBuilder(
                    currentUserUseCase: { container.profileRepository.currentUser },
                    currentUserSequenceUseCase: { container.profileRepository.currentUserSequence },
                    logoutUseCase: { await container.logoutUseCase.logout() },
                    coordinator: tabCoordinator,
                    authButtonBuilder: makeAuthButtonBuilder(
                        container: container,
                        coordinator: tabCoordinator
                    ),
                    favoriteListsManageBuilder: makeFavoriteListsManageBuilder(
                        container: container,
                        coordinator: tabCoordinator
                    )
                ).build()
                .navigationDestination(for: AppDestination.self) { destination in
                    coordinator.builder(destination, tabCoordinator)
                }
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(AppTab.profile)
        }
        .sheet(item: sheetBinding) { child in
            CoordinatorView(coordinator: child)
        }
        .fullScreenCover(item: fullScreenBinding) { child in
            CoordinatorView(coordinator: child)
        }
    }

    private var sheetBinding: Binding<Coordinator?> {
        Binding(
            get: { coordinator.presented?.style == .sheet ? coordinator.presented : nil },
            set: { newValue in if newValue == nil { coordinator.presented = nil } }
        )
    }

    private var fullScreenBinding: Binding<Coordinator?> {
        Binding(
            get: {
                coordinator.presented?.style == .fullScreenCover
                    ? coordinator.presented
                    : nil
            },
            set: { newValue in if newValue == nil { coordinator.presented = nil } }
        )
    }
}
