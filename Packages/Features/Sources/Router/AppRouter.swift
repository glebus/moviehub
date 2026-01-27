import Observation

@MainActor
@Observable
public final class AppRouter: AppRouterProtocol {
    public var selectedTab: AppTab = .home
    public var homePath: [AppDestination<AppPushDestination>] = []
    public var favoritesPath: [AppDestination<AppPushDestination>] = []
    public var profilePath: [AppDestination<AppPushDestination>] = []
    public var presentedSheet: AppDestination<AppSheetDestination>?

    public init() {}

    public func push(_ destination: AppPushDestination) {
        let wrapped = AppDestination(value: destination)
        switch selectedTab {
        case .home:
            homePath.append(wrapped)
        case .favorites:
            favoritesPath.append(wrapped)
        case .profile:
            profilePath.append(wrapped)
        }
    }

    public func present(_ destination: AppSheetDestination) {
        presentedSheet = AppDestination(value: destination)
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
