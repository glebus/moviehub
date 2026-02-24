import SwiftUI
import DomainModels
import DomainUseCases
import Router
import AuthButton
import FavoriteListsManage
import DomainMocks

@MainActor
public struct ProfileBuilder {
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let logoutUseCase: LogoutAction
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder
    private let favoriteListsManageBuilder: FavoriteListsManageBuilder

    public init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        logoutUseCase: @escaping LogoutAction,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder,
        favoriteListsManageBuilder: FavoriteListsManageBuilder
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.logoutUseCase = logoutUseCase
        self.router = router
        self.authButtonBuilder = authButtonBuilder
        self.favoriteListsManageBuilder = favoriteListsManageBuilder
    }

    public func build() -> some View {
        let viewModel = ProfileViewModel(
            currentUserUseCase: currentUserUseCase,
            currentUserSequenceUseCase: currentUserSequenceUseCase,
            logoutUseCase: logoutUseCase,
            router: router,
            authButtonBuilder: authButtonBuilder,
            favoriteListsManageBuilder: favoriteListsManageBuilder
        )
        return ProfileScreen(viewModel: viewModel)
    }

    public static func preview() -> ProfileBuilder {
        let router = AppRouterMock()
        let session = SessionUseCaseMock()
        let favoriteListsUseCases = FavoriteListsUseCaseMock()
        return ProfileBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            logoutUseCase: { await session.logout() },
            router: router,
            authButtonBuilder: AuthButtonBuilder.preview(),
            favoriteListsManageBuilder: FavoriteListsManageBuilder(
                currentUserUseCase: { session.currentUser },
                currentUserSequenceUseCase: { session.currentUserSequence },
                favoriteListsStateUseCase: { favoriteListsUseCases.lists },
                favoriteListsSequenceUseCase: { favoriteListsUseCases.listsSequence },
                refreshFavoriteListsUseCase: { try await favoriteListsUseCases.refresh() },
                renameFavoriteListUseCase: { try await favoriteListsUseCases.rename(listId: $0, name: $1) },
                deleteFavoriteListUseCase: { try await favoriteListsUseCases.delete(listId: $0) },
                router: router
            )
        )
    }
}
