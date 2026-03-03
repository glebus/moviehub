@MainActor
public protocol FlowCoordinatorProtocol: AppCoordinatorProtocol {
    func appendPathValue<Value: Hashable & Sendable>(_ value: Value)
}
