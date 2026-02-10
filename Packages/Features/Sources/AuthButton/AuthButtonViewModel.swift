import Observation
import Domain
import Router
import Utilities

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
        applySession(sessionInteractor.currentUser)
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
        streamTask = observeChanges({ [sessionInteractor] in sessionInteractor.currentUser }) { [weak self] user in
            self?.applySession(user)
        }
    }

    private func applySession(_ user: User?) {
        currentUser = user
        title = user?.username ?? "Login"
    }
}
