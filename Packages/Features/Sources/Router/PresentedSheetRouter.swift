import SwiftUI
import Observation

@MainActor
@Observable
public final class PresentedSheetRouter: AppRouterProtocol {
    public var path = NavigationPath()

    @ObservationIgnored private weak var parentRouter: AppRouter?

    init(parentRouter: AppRouter) {
        self.parentRouter = parentRouter
    }

    public func push(_ destination: AppPushDestination) {
        path.append(AppDestination(value: destination))
    }

    public func appendPathValue<Value: Hashable & Sendable>(_ value: Value) {
        path.append(value)
    }

    public func present(_ destination: AppSheetDestination) {
        parentRouter?.present(destination)
    }

    public func selectTab(_ tab: AppTab) {
        parentRouter?.selectTab(tab)
    }

    public func dismissSheet() {
        parentRouter?.dismissSheet()
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path = NavigationPath()
    }
}
