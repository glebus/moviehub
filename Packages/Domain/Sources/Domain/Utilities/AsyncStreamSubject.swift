import Foundation

public actor AsyncStreamSubject<Value: Sendable>: Sendable {
    private struct Box<T> {
        let value: T
    }

    private var continuations: [UUID: AsyncStream<Value>.Continuation] = [:]
    private var lastValue: Box<Value>?

    public init() {}

    public init(initial: Value) {
        self.lastValue = Box(value: initial)
    }

    public nonisolated var stream: AsyncStream<Value> {
        AsyncStream { continuation in
            let id = UUID()
            Task { await self.register(id: id, continuation: continuation) }
            continuation.onTermination = { _ in
                Task { await self.unregister(id: id) }
            }
        }
    }

    public func send(_ value: Value) {
        lastValue = Box(value: value)
        for continuation in continuations.values {
            continuation.yield(value)
        }
    }

    public func latest() -> Value? {
        lastValue?.value
    }

    private func register(id: UUID, continuation: AsyncStream<Value>.Continuation) async {
        continuations[id] = continuation
        if let boxed = lastValue {
            continuation.yield(boxed.value)
        }
    }

    private func unregister(id: UUID) async {
        continuations[id] = nil
    }
}
