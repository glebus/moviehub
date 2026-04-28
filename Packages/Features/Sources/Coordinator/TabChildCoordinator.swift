import Observation
import SwiftUI

@MainActor
@Observable
public final class TabChildCoordinator: CoordinatorProtocol {
    private let tab: AppTab
    private unowned let parent: TabCoordinator
    public weak var delegate: (any CoordinatorDelegate)?

    init(tab: AppTab, parent: TabCoordinator) {
        self.tab = tab
        self.parent = parent
    }

    public var path: NavigationPath {
        get { parent.path(for: tab) }
        set { parent.setPath(newValue, for: tab) }
    }

    public func present(
        _ destination: AppDestination,
        style: PresentationStyle = .sheet,
        animated: Bool = true
    ) {
        parent.present(destination, style: style, animated: animated)
    }

    public func dismiss() {
        parent.dismiss()
    }

    public func dismissAndPresent(
        _ destination: AppDestination,
        style: PresentationStyle = .sheet,
        animated: Bool = true
    ) {
        parent.dismiss()
        parent.present(destination, style: style, animated: animated)
    }

    public func pop(toRoot: Bool = false) {
        if toRoot {
            path = NavigationPath()
        } else if !path.isEmpty {
            path.removeLast()
        }
    }

    public func selectTab(_ tab: AppTab) {
        parent.selectTab(tab)
    }
}
