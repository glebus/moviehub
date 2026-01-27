@MainActor
public protocol AppRouterProtocol: AnyObject, Sendable {
    func push(_ destination: AppPushDestination)
    func present(_ destination: AppSheetDestination)
    func selectTab(_ tab: AppTab)
    func dismissSheet()
    func pop()
    func popToRoot()
}
