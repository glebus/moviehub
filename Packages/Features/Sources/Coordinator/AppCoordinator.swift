import Foundation
import Observation

@MainActor
@Observable
public final class AppCoordinator: AppCoordinatorProtocol {
    public var selectedTab: AppTab = .home
    public var homePath: [AppDestination<AppPushDestination>] = []
    public var favoritesPath: [AppDestination<AppPushDestination>] = []
    public var profilePath: [AppDestination<AppPushDestination>] = []
    public var presentationCoordinator: PresentationCoordinator?

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

    public func present(_ destination: AppPresentedDestination, style: PresentationStyle = .sheet) {
        presentationCoordinator = PresentationCoordinator(
            destination: destination,
            style: style,
            parent: self,
            dismissAction: { [weak self] in self?.presentationCoordinator = nil }
        )
    }

    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    public func dismiss() {
        presentationCoordinator = nil
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

    public var topmostCoordinator: any AppCoordinatorProtocol {
        presentationCoordinator?.topmostCoordinator ?? self
    }
}

public enum AppTab: Hashable, Sendable {
    case home
    case favorites
    case profile
}
