import SwiftUI
import Domain
import Router
import DomainMocks

@MainActor
public struct MovieListBuilder {
    private let movieRepository: MovieRepositoryProtocol
    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol

    public init(
        movieRepository: MovieRepositoryProtocol,
        sessionInteractor: SessionInteractorProtocol,
        router: AppRouterProtocol
    ) {
        self.movieRepository = movieRepository
        self.sessionInteractor = sessionInteractor
        self.router = router
    }

    public func build() -> MovieListScreen {
        let viewModel = MovieListViewModel(
            movieRepository: movieRepository,
            sessionInteractor: sessionInteractor,
            router: router
        )
        return MovieListScreen(viewModel: viewModel)
    }

    public static func preview() -> MovieListBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        let movieRepo = MovieRepositoryMock(
            searchResults: [
                Movie(id: MovieID("m1"), title: "The Man Who Knew Too Much", year: "1956", posterURL: nil),
                Movie(id: MovieID("m2"), title: "Man of Steel", year: "2013", posterURL: nil)
            ]
        )

        return MovieListBuilder(
            movieRepository: movieRepo,
            sessionInteractor: session,
            router: router
        )
    }
}
