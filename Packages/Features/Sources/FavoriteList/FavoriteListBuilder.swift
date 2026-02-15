import SwiftUI
import Domain
import Router
import AuthButton
import DomainMocks

@MainActor
public struct FavoriteListBuilder {
    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build() -> some View {
        let viewModel = FavoriteListViewModel(
            sessionInteractor: sessionInteractor,
            favoriteListsInteractor: favoriteListsInteractor,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return FavoriteListScreen(viewModel: viewModel)
    }

    public static func preview() -> FavoriteListBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock(currentUser: User(id: UserID("user"), username: "user"))
        let listsRepository = FavoriteListsRepositoryMock()
        let favoriteListsInteractor = FavoriteListsInteractor(
            listsRepository: listsRepository,
            sessionInteractor: session
        )
        Task {
            await listsRepository.seedLists([
                FavoriteList(id: FavoriteListID("l1"), name: "Comedies", color: .mint, createdAt: Date()),
                FavoriteList(id: FavoriteListID("l2"), name: "Drama", color: .indigo, createdAt: Date())
            ], for: UserID("user"))
            try? await favoriteListsInteractor.refresh()
        }

        return FavoriteListBuilder(
            sessionInteractor: session,
            favoriteListsInteractor: favoriteListsInteractor,
            router: router,
            authButtonBuilder: AuthButtonBuilder.preview()
        )
    }
}
