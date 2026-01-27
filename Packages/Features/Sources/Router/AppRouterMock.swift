@MainActor
public final class AppRouterMock: AppRouterProtocol {
    public private(set) var lastDestination: AppRoute?
    public private(set) var selectedTab: AppTab?
    public private(set) var didDismissSheet = false
    public private(set) var popCount = 0
    public private(set) var popToRootCount = 0

    public init() {}

    public func navigate(_ destination: AppRoute) {
        lastDestination = destination
    }

    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    public func dismissSheet() {
        didDismissSheet = true
    }

    public func pop() {
        popCount += 1
    }

    public func popToRoot() {
        popToRootCount += 1
    }
}
