import Foundation
import Observation

@MainActor
@Observable
public final class AppRouter: AppRouterProtocol {
    public var selectedTab: AppTab = .home
    public var homePath: [AppDestination<AppPushDestination>] = []
    public var favoritesPath: [AppDestination<AppPushDestination>] = []
    public var profilePath: [AppDestination<AppPushDestination>] = []
    public var presentedRoute: PresentedRoutePresentation?

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
        let childRouter = PresentedRouteRouter(
            parent: self,
            dismissAction: { [weak self] in self?.presentedRoute = nil }
        )
        presentedRoute = PresentedRoutePresentation(
            destination: AppDestination(value: destination),
            style: style,
            childRouter: childRouter
        )
    }

    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    public func dismiss() {
        presentedRoute = nil
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

    public var topmostRouter: any AppRouterProtocol {
        presentedRoute?.childRouter.topmostRouter ?? self
    }
}

public final class PresentedRoutePresentation: Identifiable {
    public let id = UUID()
    public let destination: AppDestination<AppPresentedDestination>
    public let style: PresentationStyle
    public let childRouter: PresentedRouteRouter

    public init(
        destination: AppDestination<AppPresentedDestination>,
        style: PresentationStyle,
        childRouter: PresentedRouteRouter
    ) {
        self.destination = destination
        self.style = style
        self.childRouter = childRouter
    }
}

public enum AppTab: Hashable, Sendable {
    case home
    case favorites
    case profile
}
