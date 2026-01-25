import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class AuthViewModel {
    public enum State: Sendable, Equatable {
        case idle
        case submitting
        case error(String)
        case success
    }

    public var username: String
    public var state: State

    private let sessionInteractor: SessionInteractor

    public init(sessionInteractor: SessionInteractor) {
        self.sessionInteractor = sessionInteractor
        self.username = ""
        self.state = .idle
    }

    public func loginTapped() {
        Task { await login() }
    }

    private func login() async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            state = .error("Please enter a username")
            return
        }

        state = .submitting
        do {
            _ = try await sessionInteractor.login(username: trimmed)
            state = .success
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
