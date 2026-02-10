import SwiftUI
import Domain
import Router
import AuthButton
import FavoriteListsManage
import DomainMocks

@MainActor
public struct ProfileBuilder {
    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder
    private let favoriteListsManageBuilder: FavoriteListsManageBuilder

    public init(
        sessionInteractor: SessionInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder,
        favoriteListsManageBuilder: FavoriteListsManageBuilder
    ) {
        self.sessionInteractor = sessionInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
        self.favoriteListsManageBuilder = favoriteListsManageBuilder
    }

    public func build() -> ProfileScreen {
        let viewModel = ProfileViewModel(
            sessionInteractor: sessionInteractor,
            router: router,
            authButtonBuilder: authButtonBuilder,
            favoriteListsManageBuilder: favoriteListsManageBuilder
        )
        return ProfileScreen(viewModel: viewModel)
    }

    public static func preview() -> ProfileBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        let listsRepository = FavoriteListsRepositoryMock()
        let listsInteractor = FavoriteListsInteractor(
            listsRepository: listsRepository,
            sessionInteractor: session
        )
        return ProfileBuilder(
            sessionInteractor: session,
            router: router,
            authButtonBuilder: AuthButtonBuilder.preview(),
            favoriteListsManageBuilder: FavoriteListsManageBuilder(
                sessionInteractor: session,
                favoriteListsInteractor: listsInteractor,
                router: router
            )
        )
    }
}
