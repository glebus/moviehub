import SwiftUI
import Observation

@MainActor
@Observable
public final class PresentedRouteRouter: AppRouterProtocol, Identifiable {
    public let id = UUID()
    public let destination: AppPresentedDestination
    public let style: PresentationStyle
    public var path = NavigationPath()
    public var presentedRoute: PresentedRouteRouter?

    @ObservationIgnored private weak var parent: (any AppRouterProtocol)?
    @ObservationIgnored private let dismissAction: @MainActor () -> Void

    init(
        destination: AppPresentedDestination,
        style: PresentationStyle,
        parent: any AppRouterProtocol,
        dismissAction: @escaping @MainActor () -> Void
    ) {
        self.destination = destination
        self.style = style
        self.parent = parent
        self.dismissAction = dismissAction
    }

    public func push(_ destination: AppPushDestination) {
        path.append(AppDestination(value: destination))
    }

    public func appendPathValue<Value: Hashable & Sendable>(_ value: Value) {
        path.append(value)
    }

    public func present(_ destination: AppPresentedDestination, style: PresentationStyle = .sheet) {
        presentedRoute = PresentedRouteRouter(
            destination: destination,
            style: style,
            parent: self,
            dismissAction: { [weak self] in self?.presentedRoute = nil }
        )
    }

    public func selectTab(_ tab: AppTab) {
        parent?.selectTab(tab)
    }

    public func dismiss() {
        dismissAction()
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path = NavigationPath()
    }

    public var topmostRouter: any AppRouterProtocol {
        presentedRoute?.topmostRouter ?? self
    }
}
