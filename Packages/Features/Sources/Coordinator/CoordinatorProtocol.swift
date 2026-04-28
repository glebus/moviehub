import SwiftUI

@MainActor
public protocol CoordinatorProtocol: AnyObject {
    var path: NavigationPath { get set }
    var delegate: (any CoordinatorDelegate)? { get set }

    func push<Value: Hashable>(_ value: Value)
    func present(_ destination: AppDestination, style: PresentationStyle, animated: Bool)
    func dismiss()
    func dismissAndPresent(_ destination: AppDestination, style: PresentationStyle, animated: Bool)
    func pop(toRoot: Bool)
    func selectTab(_ tab: AppTab)
    func prepareForPresent() async
}

public extension CoordinatorProtocol {
    func push<Value: Hashable>(_ value: Value) {
        path.append(value)
    }

    func present(_ destination: AppDestination) {
        present(destination, style: .sheet, animated: true)
    }

    func present(_ destination: AppDestination, style: PresentationStyle) {
        present(destination, style: style, animated: true)
    }

    func dismissAndPresent(_ destination: AppDestination) {
        dismissAndPresent(destination, style: .sheet, animated: true)
    }

    func dismissAndPresent(_ destination: AppDestination, style: PresentationStyle) {
        dismissAndPresent(destination, style: style, animated: true)
    }

    func prepareForPresent() async {
        await delegate?.prepareForPresent()
    }
}
