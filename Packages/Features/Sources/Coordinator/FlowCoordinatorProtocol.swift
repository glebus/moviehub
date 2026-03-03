@MainActor
public protocol FlowCoordinatorProtocol: AppCoordinatorProtocol {
    func appendPathValue<Value: Hashable>(_ value: Value)
}
