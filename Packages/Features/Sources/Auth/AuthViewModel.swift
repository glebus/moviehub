import Foundation
import Observation
import Domain
import Router

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

    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol

    init(sessionInteractor: SessionInteractorProtocol, router: AppRouterProtocol) {
        self.sessionInteractor = sessionInteractor
        self.router = router
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
            router.dismissSheet()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
