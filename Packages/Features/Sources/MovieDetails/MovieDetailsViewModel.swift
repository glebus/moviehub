import Foundation
import SwiftUI
import Observation
import DomainModels
import DomainUseCases
import AuthButton
import MovieDetailsFavoriteButton

@MainActor
@Observable
public final class MovieDetailsViewModel {
    public enum State: Sendable {
        case idle
        case loading
        case loaded(MovieDetailsPresentationModel)
        case error(String)
    }

    public var state: State

    private let movieId: MovieID
    private let movieDetailsUseCase: MovieDetailsAction
    public let authButtonBuilder: AuthButtonBuilder
    private let favoriteButtonBuilder: MovieDetailsFavoriteButtonBuilder

    private var movieDetails: MovieDetails?

    init(
        movieId: MovieID,
        movieDetailsUseCase: @escaping MovieDetailsAction,
        authButtonBuilder: AuthButtonBuilder,
        favoriteButtonBuilder: MovieDetailsFavoriteButtonBuilder
    ) {
        self.movieId = movieId
        self.movieDetailsUseCase = movieDetailsUseCase
        self.authButtonBuilder = authButtonBuilder
        self.favoriteButtonBuilder = favoriteButtonBuilder
        self.state = .idle
    }

    public func onAppear() {
        if movieDetails == nil {
            Task { await loadDetails() }
        }
    }

    @ViewBuilder
    public func favoriteButtonView() -> some View {
        if let movieDetails {
            favoriteButtonBuilder.build(movieDetails: movieDetails)
        }
    }

    func loadDetails() async {
        state = .loading
        do {
            let details = try await movieDetailsUseCase(movieId)
            movieDetails = details
            let presentation = MovieDetailsPresentationModel(
                id: details.id,
                title: details.title,
                posterURL: details.posterURL,
                overview: details.overview,
                genresText: details.genres.joined(separator: ", ")
            )
            state = .loaded(presentation)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
