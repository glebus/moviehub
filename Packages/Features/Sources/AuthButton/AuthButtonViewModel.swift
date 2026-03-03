import Observation
import DomainModels
import DomainUseCases
import Coordinator

@MainActor
@Observable
public final class AuthButtonViewModel {
    public var title: String = "Login"

    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let coordinator: AppCoordinatorProtocol
    private var currentUser: User?
    @ObservationIgnored private var streamTask: Task<Void, Never>?

    init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        coordinator: AppCoordinatorProtocol
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.coordinator = coordinator
        applySession(currentUserUseCase())
        subscribe()
    }

    deinit {
        streamTask?.cancel()
    }

    public func tapped() {
        if currentUser == nil {
            coordinator.present(.auth)
        } else {
            coordinator.selectTab(.profile)
        }
    }

    private func subscribe() {
        streamTask?.cancel()
        streamTask = Task { [weak self, currentUserSequenceUseCase] in
            for await user in currentUserSequenceUseCase() {
                guard !Task.isCancelled else { break }
                self?.applySession(user)
            }
        }
    }

    private func applySession(_ user: User?) {
        currentUser = user
        title = user?.username ?? "Login"
    }
}
