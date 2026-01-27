import Foundation
import Observation
import Domain
import Router

@MainActor
@Observable
public final class FavoriteListViewModel {
    public enum State: Sendable {
        case loggedOut
        case loading
        case loaded([Movie])
        case error(String)
    }

    public var state: State
    public var isAuthSheetPresented: Bool

    private let sessionInteractor: SessionInteractorProtocol
    private let favoritesInteractor: FavoritesInteractorProtocol
    private let router: AppRouterProtocol
    @ObservationIgnored nonisolated(unsafe) private var profileTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var favoritesTask: Task<Void, Never>?
    private var currentUser: User?

    init(
        sessionInteractor: SessionInteractorProtocol,
        favoritesInteractor: FavoritesInteractorProtocol,
        router: AppRouterProtocol
    ) {
        self.sessionInteractor = sessionInteractor
        self.favoritesInteractor = favoritesInteractor
        self.router = router
        self.state = .loggedOut
        self.isAuthSheetPresented = false
        subscribeToSession()
        subscribeToFavorites()
    }

    deinit {
        profileTask?.cancel()
        favoritesTask?.cancel()
    }

    public func loginTapped() {
        router.navigate(.auth)
    }

    public func select(movieId: MovieID) {
        router.navigate(.movieDetails(movieId))
    }

    private func subscribeToSession() {
        profileTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await user in sessionInteractor.currentUserStream {
                self.currentUser = user
                self.state = user == nil ? .loggedOut : .loading
            }
        }
    }

    private func subscribeToFavorites() {
        favoritesTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await favorites in favoritesInteractor.favoritesStream {
                self.state = self.currentUser == nil ? .loggedOut : .loaded(favorites)
            }
        }
    }
}
