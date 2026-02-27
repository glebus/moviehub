import AsyncAlgorithms

@MainActor
final class ObservableValue<Element: Sendable> {
    private let continuation: AsyncStream<Element>.Continuation

    private(set) var value: Element
    let updates: any AsyncSequence<Element, Never>

    init(
        _ initialValue: Element,
        bufferingPolicy: AsyncBufferSequencePolicy = .unbounded
    ) {
        self.value = initialValue

        var continuation: AsyncStream<Element>.Continuation?
        let stream = AsyncStream<Element>(bufferingPolicy: .unbounded) { streamContinuation in
            continuation = streamContinuation
        }

        self.continuation = continuation!
        self.updates = stream.share(bufferingPolicy: bufferingPolicy)
    }

    func send(_ newValue: Element) {
        value = newValue
        continuation.yield(newValue)
    }
}
