import Observation
import DomainModels
import DomainUseCases

@MainActor
@Observable
public final class FavoriteListCreateViewModel {
    public var listName: String
    public var selectedColor: FavoriteListColor
    public var errorMessage: String?
    public var isSaving: Bool
    public var isAddingMovieToCreatedList: Bool
    public let movieToAdd: MovieDetails?

    private let createFavoriteListUseCase: CreateFavoriteListAction
    private let addFavoriteUseCase: AddFavoriteAction
    private let currentUserUseCase: CurrentUserReader
    @ObservationIgnored private let coordinator: FavoriteListCreateCoordinator

    init(
        createFavoriteListUseCase: @escaping CreateFavoriteListAction,
        addFavoriteUseCase: @escaping AddFavoriteAction,
        currentUserUseCase: @escaping CurrentUserReader,
        movieToAdd: MovieDetails?,
        coordinator: FavoriteListCreateCoordinator
    ) {
        self.createFavoriteListUseCase = createFavoriteListUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.currentUserUseCase = currentUserUseCase
        self.movieToAdd = movieToAdd
        self.coordinator = coordinator
        self.listName = ""
        self.selectedColor = .coral
        self.errorMessage = nil
        self.isSaving = false
        self.isAddingMovieToCreatedList = false
    }

    public func nextTapped() {
        coordinator.showColor()
    }

    public func createTapped() {
        Task { await createList() }
    }

    public func closeTapped() {
        coordinator.dismiss()
    }

    public func addMoviesTapped(list: FavoriteList) {
        coordinator.showAddMovies(for: list)
    }

    public func addCreatedMovieTapped(list: FavoriteList) {
        Task { await addCreatedMovie(to: list) }
    }

    func createList() async {
        guard !listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard currentUserUseCase() != nil else {
            errorMessage = AuthRequiredError().localizedDescription
            return
        }

        isSaving = true
        defer { isSaving = false }
        do {
            let createdList = try await createFavoriteListUseCase(
                listName.trimmingCharacters(in: .whitespacesAndNewlines),
                selectedColor
            )
            coordinator.showCreated(createdList)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addCreatedMovie(to list: FavoriteList) async {
        guard let movieToAdd else { return }

        isAddingMovieToCreatedList = true
        defer { isAddingMovieToCreatedList = false }
        do {
            try await addFavoriteUseCase(movieToAdd, list.id)
            coordinator.dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
