import Observation
import DomainModels
import DomainUseCases
import Router

@MainActor
@Observable
public final class FavoriteListCreateViewModel {
    public var listName: String
    public var selectedColor: FavoriteListColor
    public var path: [FavoriteListCreateStep]
    public var errorMessage: String?
    public var isSaving: Bool

    private let createFavoriteListUseCase: CreateFavoriteListAction
    private let currentUserUseCase: CurrentUserReader
    private let router: AppRouterProtocol

    init(
        createFavoriteListUseCase: @escaping CreateFavoriteListAction,
        currentUserUseCase: @escaping CurrentUserReader,
        router: AppRouterProtocol
    ) {
        self.createFavoriteListUseCase = createFavoriteListUseCase
        self.currentUserUseCase = currentUserUseCase
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
        guard currentUserUseCase() != nil else {
            errorMessage = AuthRequiredError().localizedDescription
            return
        }

        isSaving = true
        defer { isSaving = false }
        do {
            _ = try await createFavoriteListUseCase(
                listName.trimmingCharacters(in: .whitespacesAndNewlines),
                selectedColor
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
