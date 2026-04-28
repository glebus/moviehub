import Foundation

@MainActor
protocol CoordinatorParent: AnyObject {
    func removePresentedChild(id: UUID)
    func selectTab(_ tab: AppTab)
    func present(_ destination: AppDestination, style: PresentationStyle, animated: Bool)
}
