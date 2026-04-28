import Foundation
import Observation
import DomainModels
import DomainUseCases
import Coordinator

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
    private let coordinator: any CoordinatorProtocol

    init(loginUseCase: @escaping LoginAction, coordinator: any CoordinatorProtocol) {
        self.loginUseCase = loginUseCase
        self.coordinator = coordinator
        self.username = ""
        self.state = .idle
    }

    public func loginTapped() {
        Task { await login() }
    }

    public func dismiss() {
        coordinator.dismiss()
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
            coordinator.dismiss()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
