import Foundation
import Observation

/// Continuously observes a value produced by a `read` closure using a loop-based
/// `withObservationTracking` pattern. Returns a `Task` you can cancel to stop observing.
///
/// The `onChange` closure is called immediately with the current value,
/// and then again each time the observed property changes.
///
/// - Parameters:
///   - read: A closure that reads the observed property (triggers observation tracking).
///   - onChange: A closure called with the current value on each change.
/// - Returns: A cancellable `Task` that drives the observation loop.
///
/// Example usage:
/// ```swift
/// let task = observeChanges({ interactor.currentUser }) { [weak self] user in
///     self?.currentUser = user
/// }
/// // Later: task.cancel()
/// ```
@MainActor
public func observeChanges<V: Sendable>(
    _ read: @escaping @MainActor () -> V,
    onChange: @escaping @MainActor (V) -> Void
) -> Task<Void, Never> {
    Task { @MainActor in
        onChange(read())

        while !Task.isCancelled {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                withObservationTracking {
                    _ = read()
                } onChange: {
                    continuation.resume()
                }
            }

            guard !Task.isCancelled else { return }
            onChange(read())
        }
    }
}

@MainActor
public func observeChanges<V: Sendable>(
    _ read: @escaping @MainActor () -> V,
    onChange: @escaping @MainActor (V) async -> Void
) -> Task<Void, Never> {
    Task { @MainActor in
        await onChange(read())

        while !Task.isCancelled {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                withObservationTracking {
                    _ = read()
                } onChange: {
                    continuation.resume()
                }
            }

            guard !Task.isCancelled else { return }
            await onChange(read())
        }
    }
}
