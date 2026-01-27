import Testing
import Domain
import DomainMocks
import Router
import AuthButton
@testable import MovieList

@MainActor
struct MovieListViewModelTests {
    @Test
    func submitSearchLoadsMovies() async {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        let authButtonBuilder = AuthButtonBuilder(sessionInteractor: session, router: router)
        let repo = MovieRepositoryMock(
            searchResults: [
                Movie(id: MovieID("1"), title: "Test", year: "2020", posterURL: nil)
            ]
        )
        let viewModel = MovieListViewModel(
            movieRepository: repo,
            router: router,
            authButtonBuilder: authButtonBuilder
        )

        let states = await recordChanges(count: 2, observe: { viewModel.state }) {
            viewModel.submitSearch()
        }

        guard case .loaded(let movies) = viewModel.state else {
            fail("Expected loaded state after search")
            return
        }
        #expect(movies.count == 1)
        #expect(movies.first?.title == "Test")
        #expect(states.contains { if case .loading = $0 { true } else { false } })
        #expect(states.contains { if case .loaded = $0 { true } else { false } })
    }
}
