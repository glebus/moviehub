import Observation
import Domain
import Router

@MainActor
@Observable
public final class FavoriteListCreateViewModel {
    public var listName: String
    public var selectedColor: FavoriteListColor
    public var path: [FavoriteListCreateStep]
    public var errorMessage: String?
    public var isSaving: Bool

    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol

    init(
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        sessionInteractor: SessionInteractorProtocol,
        router: AppRouterProtocol
    ) {
        self.favoriteListsInteractor = favoriteListsInteractor
        self.sessionInteractor = sessionInteractor
        self.router = router
        self.listName = ""
        self.selectedColor = .coral
        self.path = []
        self.errorMessage = nil
        self.isSaving = false
    }

    public func nextTapped() {
        path = [.color]
    }

    public func createTapped() {
        Task { await createList() }
    }

    func createList() async {
        guard !listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard sessionInteractor.currentUser != nil else {
            errorMessage = AuthRequiredError().localizedDescription
            return
        }

        isSaving = true
        defer { isSaving = false }
        do {
            _ = try await favoriteListsInteractor.create(
                name: listName.trimmingCharacters(in: .whitespacesAndNewlines),
                color: selectedColor
            )
            router.dismissSheet()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

public enum FavoriteListCreateStep: Hashable, Sendable {
    case color
}
