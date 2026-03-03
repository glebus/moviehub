import Observation

@MainActor
@Observable
public final class AppRouterMock: AppRouterProtocol {
    public private(set) var lastPushDestination: AppPushDestination?
    public private(set) var lastPresentedDestination: AppPresentedDestination?
    public private(set) var lastPresentationStyle: PresentationStyle?
    public private(set) var selectedTab: AppTab?
    public private(set) var didDismiss = false
    public private(set) var popCount = 0
    public private(set) var popToRootCount = 0

    public init() {}

    public func push(_ destination: AppPushDestination) {
        lastPushDestination = destination
    }

    public func present(_ destination: AppPresentedDestination, style: PresentationStyle = .sheet) {
        lastPresentedDestination = destination
        lastPresentationStyle = style
    }

    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    public func dismiss() {
        didDismiss = true
    }

    public func pop() {
        popCount += 1
    }

    public func popToRoot() {
        popToRootCount += 1
    }

    public var topmostRouter: any AppRouterProtocol { self }
}
