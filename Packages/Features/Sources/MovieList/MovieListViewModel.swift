import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class MovieListViewModel {
    public enum State: Sendable {
        case idle
        case loading
        case loaded([MovieTilePresentationModel])
        case error(String)
    }

    public var searchText: String
    public var profileButtonTitle: String
    public var isAuthSheetPresented: Bool
    public var isProfilePresented: Bool
    public var selectedMovieID: MovieID?
    public var state: State

    private let movieRepository: MovieRepositoryProtocol
    private let sessionInteractor: SessionInteractor
    @ObservationIgnored nonisolated(unsafe) private var profileTask: Task<Void, Never>?
    private var currentUser: User?

    public init(movieRepository: MovieRepositoryProtocol, sessionInteractor: SessionInteractor) {
        self.movieRepository = movieRepository
        self.sessionInteractor = sessionInteractor
        self.searchText = ""
        self.profileButtonTitle = "Login"
        self.isAuthSheetPresented = false
        self.isProfilePresented = false
        self.selectedMovieID = nil
        self.state = .idle
        subscribeToProfile()
    }

    deinit {
        profileTask?.cancel()
    }

    public func onAppear() {
        if case .loaded = state {
            return
        }
        searchText = searchText.isEmpty ? "Man" : searchText
        Task { await search() }
    }

    public func submitSearch() {
        Task { await search() }
    }

    public func select(movieId: MovieID) {
        selectedMovieID = movieId
    }

    public func profileButtonTapped() {
        if currentUser == nil {
            isAuthSheetPresented = true
        } else {
            isProfilePresented = true
        }
    }

    private func search() async {
        state = .loading
        do {
            let results = try await movieRepository.search(query: searchText)
            let tiles = results.map { movie in
                MovieTilePresentationModel(
                    id: movie.id,
                    title: movie.title,
                    year: movie.year,
                    posterURL: movie.posterURL
                )
            }
            state = .loaded(tiles)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func subscribeToProfile() {
        profileTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await user in sessionInteractor.currentUserStream {
                self.currentUser = user
                self.profileButtonTitle = user?.username ?? "Login"
            }
        }
    }
}
