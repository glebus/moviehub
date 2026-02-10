import Foundation
import Observation
import Domain
import Router
import AuthButton
import FavoriteListsManage
import Utilities

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
    public let favoriteListsManageBuilder: FavoriteListsManageBuilder
    @ObservationIgnored nonisolated(unsafe) private var profileTask: Task<Void, Never>?

    init(
        sessionInteractor: SessionInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder,
        favoriteListsManageBuilder: FavoriteListsManageBuilder
    ) {
        self.sessionInteractor = sessionInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
        self.favoriteListsManageBuilder = favoriteListsManageBuilder
        self.state = .loggedOut
        self.isAuthSheetPresented = false
        self.errorMessage = nil
        applyProfile(sessionInteractor.currentUser)
        subscribeToProfile()
    }

    deinit {
        profileTask?.cancel()
    }

    public func logoutTapped() {
        Task { await logout() }
    }

    func logout() async {
        await sessionInteractor.logout()
        applyProfile(sessionInteractor.currentUser)
    }

    private func subscribeToProfile() {
        profileTask = observeChanges({ [sessionInteractor] in sessionInteractor.currentUser }) { [weak self] user in
            self?.applyProfile(user)
        }
    }

    private func applyProfile(_ user: User?) {
        if let user {
            state = .loggedIn(username: user.username)
        } else {
            state = .loggedOut
        }
    }
}
