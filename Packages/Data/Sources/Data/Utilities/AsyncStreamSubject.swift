import Foundation

actor AsyncStreamSubject<Value: Sendable>: Sendable {
    private var continuations: [UUID: AsyncStream<Value>.Continuation] = [:]
    private var lastValue: Value?

    func send(_ value: Value) {
        lastValue = value
        for continuation in continuations.values {
            continuation.yield(value)
        }
    }

    nonisolated func stream() -> AsyncStream<Value> {
        AsyncStream { continuation in
            let id = UUID()
            Task { await self.register(id: id, continuation: continuation) }
            continuation.onTermination = { _ in
                Task { await self.unregister(id: id) }
            }
        }
    }

    private func register(id: UUID, continuation: AsyncStream<Value>.Continuation) {
        continuations[id] = continuation
        if let lastValue {
            continuation.yield(lastValue)
        }
    }

    private func unregister(id: UUID) {
        continuations[id] = nil
    }
}
