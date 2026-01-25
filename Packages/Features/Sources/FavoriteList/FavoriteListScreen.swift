import SwiftUI
import Domain

public struct FavoriteListDependencies: Sendable {
    public let profileRepository: ProfileRepositoryProtocol
    public let favoritesRepository: FavoritesRepositoryProtocol
    public let makeMovieDetailsScreen: @MainActor (MovieID) -> AnyView
    public let makeAuthScreen: @MainActor () -> AnyView

    public init(
        profileRepository: ProfileRepositoryProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        makeMovieDetailsScreen: @escaping @MainActor (MovieID) -> AnyView,
        makeAuthScreen: @escaping @MainActor () -> AnyView
    ) {
        self.profileRepository = profileRepository
        self.favoritesRepository = favoritesRepository
        self.makeMovieDetailsScreen = makeMovieDetailsScreen
        self.makeAuthScreen = makeAuthScreen
    }
}

public struct FavoriteListScreen: View {
    @State private var viewModel: FavoriteListViewModel
    private let dependencies: FavoriteListDependencies

    public init(dependencies: FavoriteListDependencies) {
        self.dependencies = dependencies
        _viewModel = State(
            initialValue: FavoriteListViewModel(
                profileRepository: dependencies.profileRepository,
                favoritesRepository: dependencies.favoritesRepository
            )
        )
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            Group {
                switch viewModel.state {
                case .loggedOut:
                    VStack(spacing: 12) {
                        Text("Not logged in")
                            .font(.headline)
                        Button("Login") {
                            viewModel.loginTapped()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loading:
                    ProgressView()
                case .loaded(let favorites):
                    List(favorites, id: \.id) { movie in
                        NavigationLink(value: movie.id) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(movie.title)
                                    .font(.headline)
                                if let year = movie.year {
                                    Text(year)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                case .error(let message):
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Favorites")
            .navigationDestination(for: MovieID.self) { movieId in
                dependencies.makeMovieDetailsScreen(movieId)
            }
            .sheet(isPresented: $viewModel.isAuthSheetPresented) {
                dependencies.makeAuthScreen()
            }
        }
    }
}
