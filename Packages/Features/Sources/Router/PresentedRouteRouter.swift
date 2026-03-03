import SwiftUI
import Observation

@MainActor
@Observable
public final class PresentedRouteRouter: AppRouterProtocol {
    public var path = NavigationPath()
    public var presentedRoute: PresentedRoutePresentation?

    @ObservationIgnored private weak var parent: (any AppRouterProtocol)?
    @ObservationIgnored private let dismissAction: @MainActor () -> Void

    init(parent: any AppRouterProtocol, dismissAction: @escaping @MainActor () -> Void) {
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
        presentedRoute?.childRouter.topmostRouter ?? self
    }
}
