import DomainModels
import DomainRepositories

@MainActor
func requireCurrentUser(from profileRepository: ProfileRepositoryProtocol) throws -> User {
    guard let user = profileRepository.currentUser else {
        throw AuthRequiredError()
    }
    return user
}
