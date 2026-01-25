import Foundation
import Observation
import Domain

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
    public var selectedMovieID: MovieID?

    private let sessionInteractor: SessionInteractor
    private let favoritesInteractor: FavoritesInteractor
    @ObservationIgnored nonisolated(unsafe) private var profileTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var favoritesTask: Task<Void, Never>?
    private var currentUser: User?

    public init(
        sessionInteractor: SessionInteractor,
        favoritesInteractor: FavoritesInteractor
    ) {
        self.sessionInteractor = sessionInteractor
        self.favoritesInteractor = favoritesInteractor
        self.state = .loggedOut
        self.isAuthSheetPresented = false
        self.selectedMovieID = nil
        subscribeToSession()
        subscribeToFavorites()
    }

    deinit {
        profileTask?.cancel()
        favoritesTask?.cancel()
    }

    public func loginTapped() {
        isAuthSheetPresented = true
    }

    public func select(movieId: MovieID) {
        selectedMovieID = movieId
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
