import Foundation
import Observation

@MainActor
@Observable
public final class SessionInteractor: SessionInteractorProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    public private(set) var currentUser: User?

    public init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    public func login(username: String) async throws -> User {
        let normalized = UsernameNormalizer.normalize(username)
        if let existing = try await profileRepository.findUser(username: normalized) {
            currentUser = existing
            return existing
        }

        let created = try await profileRepository.createUser(username: normalized)
        currentUser = created
        return created
    }

    public func logout() async {
        currentUser = nil
    }
}
