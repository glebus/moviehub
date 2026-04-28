import Foundation
import Observation
import DomainModels
import DomainUseCases
import Coordinator
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

    private let searchMoviesUseCase: SearchMoviesAction
    private let coordinator: any CoordinatorProtocol
    public let authButtonBuilder: AuthButtonBuilder

    init(
        searchMoviesUseCase: @escaping SearchMoviesAction,
        coordinator: any CoordinatorProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.coordinator = coordinator
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
        coordinator.push(AppDestination.movieDetails(movieId))
    }

    func search() async {
        state = .loading
        do {
            let results = try await searchMoviesUseCase(searchText)
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
