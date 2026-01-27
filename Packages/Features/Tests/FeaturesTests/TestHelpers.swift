import Foundation
import Testing
import Observation

@MainActor
func waitForChange(
    _ observe: @escaping @MainActor @Sendable () -> Void
) async {
    await withCheckedContinuation { continuation in
        withObservationTracking {
            observe()
        } onChange: {
            continuation.resume()
        }
    }
}

@MainActor
func recordChanges<T>(
    count: Int,
    observe: @escaping @MainActor @Sendable () -> T,
    perform: @escaping @MainActor @Sendable () -> Void
) async -> [T] {
    var values: [T] = [observe()]
    guard count > 0 else { return values }

    await waitForChange {
        _ = observe()
        perform()
    }
    values.append(observe())

    if count > 1 {
        for _ in 1..<count {
            await waitForChange { _ = observe() }
            values.append(observe())
        }
    }
    return values
}

@MainActor
func recordChanges<T>(
    count: Int,
    observe: @escaping @MainActor @Sendable () -> T
) async -> [T] {
    await recordChanges(count: count, observe: observe, perform: {})
}

@MainActor
@inline(__always)
func fail(_ message: String) {
    #expect(Bool(false), Comment(rawValue: message))
}
