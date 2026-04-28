import Observation
import SwiftUI

@MainActor
@Observable
public final class CoordinatorMock: CoordinatorProtocol {
    public var path = NavigationPath()
    public weak var delegate: (any CoordinatorDelegate)?

    public private(set) var pushedValues: [AnyHashable] = []
    public private(set) var presentedDestination: AppDestination?
    public private(set) var presentedStyle: PresentationStyle?
    public private(set) var dismissed = false
    public private(set) var dismissedAndPresentedDestination: AppDestination?
    public private(set) var selectedTab: AppTab?
    public private(set) var popToRoot: Bool?
    public private(set) var prepareForPresentCalled = false

    public init() {}

    public func push<Value: Hashable>(_ value: Value) {
        pushedValues.append(AnyHashable(value))
        path.append(value)
    }

    public func present(
        _ destination: AppDestination,
        style: PresentationStyle = .sheet,
        animated: Bool = true
    ) {
        presentedDestination = destination
        presentedStyle = style
    }

    public func dismiss() {
        dismissed = true
    }

    public func dismissAndPresent(
        _ destination: AppDestination,
        style: PresentationStyle = .sheet,
        animated: Bool = true
    ) {
        dismissedAndPresentedDestination = destination
        presentedStyle = style
    }

    public func pop(toRoot: Bool = false) {
        self.popToRoot = toRoot
    }

    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    public func prepareForPresent() async {
        prepareForPresentCalled = true
        await delegate?.prepareForPresent()
    }
}
