import Observation

@MainActor
@Observable
public final class AppRouter: AppRouterProtocol {
    public var selectedTab: AppTab = .home
    public var homePath: [AppDestination<AppRoute>] = []
    public var favoritesPath: [AppDestination<AppRoute>] = []
    public var profilePath: [AppDestination<AppRoute>] = []
    public var presentedSheet: AppDestination<AppRoute>?

    public init() {}

    public func navigate(_ destination: AppRoute) {
        let wrapped = AppDestination(value: destination)
        switch destination {
        case .auth:
            presentedSheet = wrapped
        case .movieDetails:
            switch selectedTab {
            case .home:
                homePath.append(wrapped)
            case .favorites:
                favoritesPath.append(wrapped)
            case .profile:
                profilePath.append(wrapped)
            }
        }
    }

    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    public func dismissSheet() {
        presentedSheet = nil
    }

    public func pop() {
        switch selectedTab {
        case .home:
            _ = homePath.popLast()
        case .favorites:
            _ = favoritesPath.popLast()
        case .profile:
            _ = profilePath.popLast()
        }
    }

    public func popToRoot() {
        switch selectedTab {
        case .home:
            homePath.removeAll()
        case .favorites:
            favoritesPath.removeAll()
        case .profile:
            profilePath.removeAll()
        }
    }
}

public enum AppTab: Hashable, Sendable {
    case home
    case favorites
    case profile
}
