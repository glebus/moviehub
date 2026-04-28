import Observation
import SwiftUI

@MainActor
@Observable
public final class TabCoordinator: CoordinatorParent {
    public var selectedTab: AppTab = .home
    public var homePath = NavigationPath()
    public var favoritesPath = NavigationPath()
    public var profilePath = NavigationPath()
    public var presented: Coordinator?
    public private(set) var children: [AppTab: TabChildCoordinator] = [:]

    @ObservationIgnored public let builder: CoordinatorBuilder

    public init(builder: @escaping CoordinatorBuilder) {
        self.builder = builder
        for tab in AppTab.allCases {
            children[tab] = TabChildCoordinator(tab: tab, parent: self)
        }
    }

    public func child(for tab: AppTab) -> TabChildCoordinator {
        guard let child = children[tab] else {
            preconditionFailure("Missing child coordinator for \(tab)")
        }
        return child
    }

    public func path(for tab: AppTab) -> NavigationPath {
        switch tab {
        case .home:
            homePath
        case .favorites:
            favoritesPath
        case .profile:
            profilePath
        }
    }

    public func setPath(_ path: NavigationPath, for tab: AppTab) {
        switch tab {
        case .home:
            homePath = path
        case .favorites:
            favoritesPath = path
        case .profile:
            profilePath = path
        }
    }

    public func bindingForPath(_ tab: AppTab) -> Binding<NavigationPath> {
        Binding(
            get: { self.path(for: tab) },
            set: { self.setPath($0, for: tab) }
        )
    }

    public func present(
        _ destination: AppDestination,
        style: PresentationStyle = .sheet,
        animated: Bool = true
    ) {
        presented = Coordinator(
            destination: destination,
            style: style,
            parent: self,
            builder: builder
        )
    }

    public func dismiss() {
        presented = nil
    }

    public func prepareForPresent() async {
        presented = nil
        for child in children.values {
            await child.prepareForPresent()
        }
    }

    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    func removePresentedChild(id: UUID) {
        guard presented?.id == id else { return }
        presented = nil
    }
}
