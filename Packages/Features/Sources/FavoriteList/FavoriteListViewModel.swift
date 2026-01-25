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

    private let profileRepository: ProfileRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    @ObservationIgnored nonisolated(unsafe) private var profileTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var favoritesTask: Task<Void, Never>?
    private var currentUser: User?

    public init(
        profileRepository: ProfileRepositoryProtocol,
        favoritesRepository: FavoritesRepositoryProtocol
    ) {
        self.profileRepository = profileRepository
        self.favoritesRepository = favoritesRepository
        self.state = .loggedOut
        self.isAuthSheetPresented = false
        self.selectedMovieID = nil
        subscribeToProfile()
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

    private func subscribeToProfile() {
        profileTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await user in profileRepository.currentUserStream {
                self.currentUser = user
                await updateFavoritesSubscription(for: user)
            }
        }
    }

    private func updateFavoritesSubscription(for user: User?) async {
        favoritesTask?.cancel()
        guard let user else {
            state = .loggedOut
            return
        }

        state = .loading
        favoritesTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await favorites in favoritesRepository.favoritesStream(userId: user.id) {
                self.state = .loaded(favorites)
            }
        }
    }
}
