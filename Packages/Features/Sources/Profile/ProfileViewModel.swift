import Foundation
import Observation
import DomainModels
import DomainUseCases
import Coordinator
import AuthButton
import FavoriteListsManage

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

    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let logoutUseCase: LogoutAction
    private let coordinator: AppCoordinatorProtocol
    public let authButtonBuilder: AuthButtonBuilder
    public let favoriteListsManageBuilder: FavoriteListsManageBuilder
    @ObservationIgnored nonisolated(unsafe) private var profileTask: Task<Void, Never>?

    init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        logoutUseCase: @escaping LogoutAction,
        coordinator: AppCoordinatorProtocol,
        authButtonBuilder: AuthButtonBuilder,
        favoriteListsManageBuilder: FavoriteListsManageBuilder
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.logoutUseCase = logoutUseCase
        self.coordinator = coordinator
        self.authButtonBuilder = authButtonBuilder
        self.favoriteListsManageBuilder = favoriteListsManageBuilder
        self.state = .loggedOut
        self.isAuthSheetPresented = false
        self.errorMessage = nil
        applyProfile(currentUserUseCase())
        subscribeToProfile()
    }

    deinit {
        profileTask?.cancel()
    }

    public func logoutTapped() {
        Task { await logout() }
    }

    func logout() async {
        await logoutUseCase()
        applyProfile(currentUserUseCase())
    }

    private func subscribeToProfile() {
        profileTask?.cancel()
        profileTask = Task { [weak self, currentUserSequenceUseCase] in
            for await user in currentUserSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.applyProfile(user)
            }
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
