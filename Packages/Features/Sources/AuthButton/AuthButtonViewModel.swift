import Observation
import Domain
import Router

@MainActor
@Observable
public final class AuthButtonViewModel {
    public var title: String = "Login"

    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol
    private var currentUser: User?
    @ObservationIgnored private var streamTask: Task<Void, Never>?

    init(sessionInteractor: SessionInteractorProtocol, router: AppRouterProtocol) {
        self.sessionInteractor = sessionInteractor
        self.router = router
        subscribe()
    }

    deinit {
        streamTask?.cancel()
    }

    public func tapped() {
        if currentUser == nil {
            router.present(.auth)
        } else {
            router.selectTab(.profile)
        }
    }

    private func subscribe() {
        streamTask = Task { [weak self] in
            guard let self else { return }
            for await user in sessionInteractor.currentUserStream {
                currentUser = user
                title = user?.username ?? "Login"
            }
        }
    }
}
