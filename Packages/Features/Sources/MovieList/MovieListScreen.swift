import SwiftUI
import Domain

public struct MovieListDependencies: Sendable {
    public let movieRepository: MovieRepositoryProtocol
    public let sessionInteractor: SessionInteractor
    public let makeMovieDetailsScreen: @MainActor (MovieID) -> AnyView
    public let makeProfileScreen: @MainActor () -> AnyView
    public let makeAuthScreen: @MainActor () -> AnyView

    public init(
        movieRepository: MovieRepositoryProtocol,
        sessionInteractor: SessionInteractor,
        makeMovieDetailsScreen: @escaping @MainActor (MovieID) -> AnyView,
        makeProfileScreen: @escaping @MainActor () -> AnyView,
        makeAuthScreen: @escaping @MainActor () -> AnyView
    ) {
        self.movieRepository = movieRepository
        self.sessionInteractor = sessionInteractor
        self.makeMovieDetailsScreen = makeMovieDetailsScreen
        self.makeProfileScreen = makeProfileScreen
        self.makeAuthScreen = makeAuthScreen
    }
}

public struct MovieListScreen: View {
    @State private var viewModel: MovieListViewModel
    private let dependencies: MovieListDependencies

    public init(dependencies: MovieListDependencies) {
        self.dependencies = dependencies
        _viewModel = State(
            initialValue: MovieListViewModel(
                movieRepository: dependencies.movieRepository,
                sessionInteractor: dependencies.sessionInteractor
            )
        )
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 16) {
                SearchBarView(text: $viewModel.searchText) {
                    viewModel.submitSearch()
                }

                switch viewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                case .loaded(let movies):
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                            ForEach(movies) { movie in
                                NavigationLink(value: movie.id) {
                                    MovieTileView(movie: movie)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                case .error(let message):
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .navigationTitle("Movies")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(viewModel.profileButtonTitle) {
                        viewModel.profileButtonTapped()
                    }
                }
            }
            .navigationDestination(for: MovieID.self) { movieId in
                dependencies.makeMovieDetailsScreen(movieId)
            }
            .sheet(isPresented: $viewModel.isAuthSheetPresented) {
                dependencies.makeAuthScreen()
            }
            .sheet(isPresented: $viewModel.isProfilePresented) {
                dependencies.makeProfileScreen()
            }
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}
