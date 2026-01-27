import Foundation
import Observation
import Domain
import Router
import AuthButton

@MainActor
@Observable
public final class ProfileViewModel {
    public enum State: Sendable {
        case loggedOut
        case loggedIn(username: String)
    }

    public var state: State
    public var isAuthSheetPresented: Bool
    public var errorMessage: String?

    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol
    public let authButtonBuilder: AuthButtonBuilder
    @ObservationIgnored nonisolated(unsafe) private var profileTask: Task<Void, Never>?

    init(
        sessionInteractor: SessionInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.sessionInteractor = sessionInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
        self.state = .loggedOut
        self.isAuthSheetPresented = false
        self.errorMessage = nil
        subscribeToProfile()
    }

    deinit {
        profileTask?.cancel()
    }

    public func logoutTapped() {
        Task { await sessionInteractor.logout() }
    }

    private func subscribeToProfile() {
        profileTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await user in sessionInteractor.currentUserStream {
                if let user {
                    self.state = .loggedIn(username: user.username)
                } else {
                    self.state = .loggedOut
                }
            }
        }
    }
}
