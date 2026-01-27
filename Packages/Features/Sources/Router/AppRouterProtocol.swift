@MainActor
public protocol AppRouterProtocol: AnyObject, Sendable {
    func navigate(_ destination: AppRoute)
    func dismissSheet()
    func pop()
    func popToRoot()
}
