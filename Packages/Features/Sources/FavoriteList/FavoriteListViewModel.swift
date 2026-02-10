import Foundation
import Observation
import Domain
import Router
import AuthButton
import Utilities

@MainActor
@Observable
public final class FavoriteListViewModel {
    public enum State: Sendable {
        case idle
        case loaded([Movie])
        case error(String)
    }

    public var state: State {
        if currentUser == nil {
            return .idle
        }
        return .loaded(favorites)
    }

    public var favorites: [Movie] = []
    public var currentUser: User?

    private let sessionInteractor: SessionInteractorProtocol
    private let favoritesInteractor: FavoritesInteractorProtocol
    private let router: AppRouterProtocol
    public let authButtonBuilder: AuthButtonBuilder

    @ObservationIgnored private var profileTask: Task<Void, Never>?
    @ObservationIgnored private var favoritesTask: Task<Void, Never>?

    init(
        sessionInteractor: SessionInteractorProtocol,
        favoritesInteractor: FavoritesInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.sessionInteractor = sessionInteractor
        self.favoritesInteractor = favoritesInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    deinit {
        profileTask?.cancel()
        favoritesTask?.cancel()
    }

    public func onAppear() {
        subscribeToSession()
        subscribeToFavorites()
    }

    public func select(movieId: MovieID) {
        router.push(.movieDetails(movieId))
    }

    private func subscribeToSession() {
        profileTask?.cancel()
        profileTask = observeChanges({ [sessionInteractor] in sessionInteractor.currentUser }) { [weak self] user in
            self?.currentUser = user
        }
    }

    private func subscribeToFavorites() {
        favoritesTask?.cancel()
        favoritesTask = observeChanges({ [favoritesInteractor] in favoritesInteractor.favorites }) { [weak self] favorites in
            self?.favorites = favorites
        }
    }
}
