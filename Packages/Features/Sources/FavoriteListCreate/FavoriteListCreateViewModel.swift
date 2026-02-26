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

    private let createFavoriteListUseCase: CreateFavoriteListAction
    private let currentUserUseCase: CurrentUserReader
    @ObservationIgnored private let coordinator: FavoriteListCreateCoordinator

    init(
        createFavoriteListUseCase: @escaping CreateFavoriteListAction,
        currentUserUseCase: @escaping CurrentUserReader,
        coordinator: FavoriteListCreateCoordinator
    ) {
        self.createFavoriteListUseCase = createFavoriteListUseCase
        self.currentUserUseCase = currentUserUseCase
        self.coordinator = coordinator
        self.listName = ""
        self.selectedColor = .coral
        self.errorMessage = nil
        self.isSaving = false
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
}
