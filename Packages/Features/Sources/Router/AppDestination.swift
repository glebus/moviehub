import Domain

public struct AppDestination<Value: Hashable & Sendable>: Identifiable, Equatable, Hashable, Sendable {
    public let value: Value
    public var id: Int { value.hashValue }

    public init(value: Value) {
        self.value = value
    }
}

public enum AppPushDestination: Hashable, Sendable {
    case movieDetails(MovieID)
}

public enum AppSheetDestination: Hashable, Sendable {
    case auth
}
