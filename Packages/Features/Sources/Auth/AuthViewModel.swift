import Foundation
import Observation
import DomainModels
import DomainUseCases
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

    private let loginUseCase: LoginAction
    private let router: AppRouterProtocol

    init(loginUseCase: @escaping LoginAction, router: AppRouterProtocol) {
        self.loginUseCase = loginUseCase
        self.router = router
        self.username = ""
        self.state = .idle
    }

    public func loginTapped() {
        Task { await login() }
    }

    func login() async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            state = .error("Please enter a username")
            return
        }

        state = .submitting
        do {
            _ = try await loginUseCase(trimmed)
            state = .success
            router.dismiss()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
