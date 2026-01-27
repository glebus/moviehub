@MainActor
public protocol AppRouterProtocol: AnyObject, Sendable {
    func navigate(_ destination: AppRoute)
    func selectTab(_ tab: AppTab)
    func dismissSheet()
    func pop()
    func popToRoot()
}
