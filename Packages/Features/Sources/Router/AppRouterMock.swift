import Observation

@MainActor
@Observable
public final class AppRouterMock: AppRouterProtocol {
    public private(set) var lastPushDestination: AppPushDestination?
    public private(set) var lastSheetDestination: AppSheetDestination?
    public private(set) var selectedTab: AppTab?
    public private(set) var didDismissSheet = false
    public private(set) var popCount = 0
    public private(set) var popToRootCount = 0

    public init() {}

    public func push(_ destination: AppPushDestination) {
        lastPushDestination = destination
    }

    public func present(_ destination: AppSheetDestination) {
        lastSheetDestination = destination
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
