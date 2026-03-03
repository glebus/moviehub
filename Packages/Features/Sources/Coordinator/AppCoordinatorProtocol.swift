@MainActor
public protocol AppCoordinatorProtocol: AnyObject, Sendable {
    func push(_ destination: AppPushDestination)
    func present(_ destination: AppPresentedDestination, style: PresentationStyle)
    func selectTab(_ tab: AppTab)
    func dismiss()
    func pop()
    func popToRoot()
    var topmostCoordinator: any AppCoordinatorProtocol { get }
}

extension AppCoordinatorProtocol {
    public func present(_ destination: AppPresentedDestination) {
        present(destination, style: .sheet)
    }
}
