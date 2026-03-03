import Testing
import DomainModels
import DomainUseCases
import DomainMocks
import Coordinator
import AuthButton
@testable import MovieList

@MainActor
struct MovieListViewModelTests {
    @Test
    func submitSearchLoadsMovies() async {
        let coordinator = AppCoordinatorMock()
        let session = SessionUseCaseMock()
        let authButtonBuilder = AuthButtonBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            coordinator: coordinator
        )
        let repo = MovieRepositoryMock(
            searchResults: [
                Movie(id: MovieID("1"), title: "Test", year: "2020", posterURL: nil)
            ]
        )
        let viewModel = MovieListViewModel(
            searchMoviesUseCase: { query in try await repo.search(query: query) },
            coordinator: coordinator,
            authButtonBuilder: authButtonBuilder
        )

        await viewModel.search()

        guard case .loaded(let movies) = viewModel.state else {
            fail("Expected loaded state after search")
            return
        }
        #expect(movies.count == 1)
        #expect(movies.first?.title == "Test")
    }
}
