import SwiftUI
import DomainModels
import DomainUseCases
import Coordinator
import AuthButton
import MovieDetailsFavoriteButton
import DomainMocks

@MainActor
public struct MovieDetailsBuilder {
    private let movieDetailsUseCase: MovieDetailsAction
    private let authButtonBuilder: AuthButtonBuilder
    private let favoriteButtonBuilder: MovieDetailsFavoriteButtonBuilder

    public init(
        movieDetailsUseCase: @escaping MovieDetailsAction,
        authButtonBuilder: AuthButtonBuilder,
        favoriteButtonBuilder: MovieDetailsFavoriteButtonBuilder
    ) {
        self.movieDetailsUseCase = movieDetailsUseCase
        self.authButtonBuilder = authButtonBuilder
        self.favoriteButtonBuilder = favoriteButtonBuilder
    }

    public func build(movieId: MovieID) -> MovieDetailsScreen {
        let viewModel = MovieDetailsViewModel(
            movieId: movieId,
            movieDetailsUseCase: movieDetailsUseCase,
            authButtonBuilder: authButtonBuilder,
            favoriteButtonBuilder: favoriteButtonBuilder
        )
        return MovieDetailsScreen(viewModel: viewModel)
    }

    public static func preview(movieId: MovieID = MovieID("m1")) -> MovieDetailsBuilder {
        let movieRepo = MovieRepositoryMock(
            detailsResult: MovieDetails(
                id: movieId,
                title: "Preview Movie",
                posterURL: nil,
                overview: "A preview overview for the movie details screen.",
                genres: ["Drama", "Action"],
                imdbURL: nil
            )
        )
        let favoriteButtonBuilder = MovieDetailsFavoriteButtonBuilder.preview(movieId: movieId)

        return MovieDetailsBuilder(
            movieDetailsUseCase: { id in try await movieRepo.details(id: id) },
            authButtonBuilder: AuthButtonBuilder.preview(),
            favoriteButtonBuilder: favoriteButtonBuilder
        )
    }
}
