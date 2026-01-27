import Foundation
import Observation
import Domain
import Router

@MainActor
@Observable
public final class MovieListViewModel {
    public enum State: Sendable {
        case idle
        case loading
        case loaded([MovieTilePresentationModel])
        case error(String)
    }

    public var searchText: String = "spider-man"
    public var profileButtonTitle: String
    public var state: State

    private let movieRepository: MovieRepositoryProtocol
    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol
    @ObservationIgnored nonisolated(unsafe) private var profileTask: Task<Void, Never>?
    private var currentUser: User?

    init(
        movieRepository: MovieRepositoryProtocol,
        sessionInteractor: SessionInteractorProtocol,
        router: AppRouterProtocol
    ) {
        self.movieRepository = movieRepository
        self.sessionInteractor = sessionInteractor
        self.router = router
        self.profileButtonTitle = "Login"
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
        Task { await search() }
    }

    public func submitSearch() {
        Task { await search() }
    }

    public func select(movieId: MovieID) {
        router.navigate(.movieDetails(movieId))
    }

    public func profileButtonTapped() {
        if currentUser == nil {
            router.navigate(.auth)
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
