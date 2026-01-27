import Foundation
import Observation
import Domain
import Router
import AuthButton

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
    public var state: State

    private let movieRepository: MovieRepositoryProtocol
    private let router: AppRouterProtocol
    public let authButtonBuilder: AuthButtonBuilder

    init(
        movieRepository: MovieRepositoryProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.movieRepository = movieRepository
        self.router = router
        self.authButtonBuilder = authButtonBuilder
        self.state = .idle
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
        router.push(.movieDetails(movieId))
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
}
