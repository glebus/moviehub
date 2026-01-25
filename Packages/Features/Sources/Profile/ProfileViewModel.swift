import Foundation
import Observation
import Domain

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

    private let profileRepository: ProfileRepositoryProtocol
    @ObservationIgnored nonisolated(unsafe) private var profileTask: Task<Void, Never>?

    public init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
        self.state = .loggedOut
        self.isAuthSheetPresented = false
        self.errorMessage = nil
        subscribeToProfile()
    }

    deinit {
        profileTask?.cancel()
    }

    public func logoutTapped() {
        Task { await profileRepository.logout() }
    }

    public func loginTapped() {
        isAuthSheetPresented = true
    }

    private func subscribeToProfile() {
        profileTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await user in profileRepository.currentUserStream {
                if let user {
                    self.state = .loggedIn(username: user.username)
                } else {
                    self.state = .loggedOut
                }
            }
        }
    }
}
