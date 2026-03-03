import SwiftUI
import DomainModels
import DomainUseCases
import Coordinator
import AuthButton
import DomainMocks

@MainActor
public struct MovieListBuilder {
    private let searchMoviesUseCase: SearchMoviesAction
    private let coordinator: AppCoordinatorProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        searchMoviesUseCase: @escaping SearchMoviesAction,
        coordinator: AppCoordinatorProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.coordinator = coordinator
        self.authButtonBuilder = authButtonBuilder
    }

    public func build() -> some View {
        let viewModel = MovieListViewModel(
            searchMoviesUseCase: searchMoviesUseCase,
            coordinator: coordinator,
            authButtonBuilder: authButtonBuilder
        )
        return MovieListScreen(viewModel: viewModel)
    }

    public static func preview() -> MovieListBuilder {
        let coordinator = AppCoordinatorMock()
        let movieRepo = MovieRepositoryMock(
            searchResults: [
                Movie(id: MovieID("m1"), title: "The Man Who Knew Too Much", year: "1956", posterURL: nil),
                Movie(id: MovieID("m2"), title: "Man of Steel", year: "2013", posterURL: nil)
            ]
        )

        return MovieListBuilder(
            searchMoviesUseCase: { query in try await movieRepo.search(query: query) },
            coordinator: coordinator,
            authButtonBuilder: AuthButtonBuilder.preview()
        )
    }
}
