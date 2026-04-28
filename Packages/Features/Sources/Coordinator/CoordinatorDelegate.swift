@MainActor
public protocol CoordinatorDelegate: AnyObject {
    func prepareForPresent() async
}
