import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
public final class Coordinator: CoordinatorProtocol, CoordinatorParent, Identifiable {
    public let id = UUID()
    public let destination: AppDestination
    public let style: PresentationStyle
    public var path = NavigationPath()
    public var presented: Coordinator?
    public weak var delegate: (any CoordinatorDelegate)?

    @ObservationIgnored private weak var parent: (any CoordinatorParent)?
    @ObservationIgnored public let builder: CoordinatorBuilder

    init(
        destination: AppDestination,
        style: PresentationStyle,
        parent: any CoordinatorParent,
        builder: @escaping CoordinatorBuilder
    ) {
        self.destination = destination
        self.style = style
        self.parent = parent
        self.builder = builder
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
        parent?.removePresentedChild(id: id)
    }

    public func dismissAndPresent(
        _ destination: AppDestination,
        style: PresentationStyle = .sheet,
        animated: Bool = true
    ) {
        parent?.removePresentedChild(id: id)
        parent?.present(destination, style: style, animated: animated)
    }

    public func pop(toRoot: Bool = false) {
        if toRoot {
            path = NavigationPath()
        } else if !path.isEmpty {
            path.removeLast()
        }
    }

    public func selectTab(_ tab: AppTab) {
        parent?.selectTab(tab)
    }

    func removePresentedChild(id: UUID) {
        guard presented?.id == id else { return }
        presented = nil
    }
}
