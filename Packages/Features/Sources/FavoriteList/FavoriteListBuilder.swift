import SwiftUI
import DomainModels
import DomainUseCases
import Router
import AuthButton
import DomainMocks

@MainActor
public struct FavoriteListBuilder {
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let favoriteListsStateUseCase: FavoriteListsReader
    private let favoriteListsSequenceUseCase: FavoriteListsSequenceSource
    private let refreshFavoriteListsUseCase: RefreshFavoriteListsAction
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        favoriteListsStateUseCase: @escaping FavoriteListsReader,
        favoriteListsSequenceUseCase: @escaping FavoriteListsSequenceSource,
        refreshFavoriteListsUseCase: @escaping RefreshFavoriteListsAction,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.favoriteListsStateUseCase = favoriteListsStateUseCase
        self.favoriteListsSequenceUseCase = favoriteListsSequenceUseCase
        self.refreshFavoriteListsUseCase = refreshFavoriteListsUseCase
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build() -> some View {
        let viewModel = FavoriteListViewModel(
            currentUserUseCase: currentUserUseCase,
            currentUserSequenceUseCase: currentUserSequenceUseCase,
            favoriteListsStateUseCase: favoriteListsStateUseCase,
            favoriteListsSequenceUseCase: favoriteListsSequenceUseCase,
            refreshFavoriteListsUseCase: refreshFavoriteListsUseCase,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return FavoriteListScreen(viewModel: viewModel)
    }

    public static func preview() -> FavoriteListBuilder {
        let router = AppRouterMock()
        let session = SessionUseCaseMock(currentUser: User(id: UserID("user"), username: "user"))
        let favoriteListsUseCases = FavoriteListsUseCaseMock(lists: [
            FavoriteList(id: FavoriteListID("l1"), name: "Comedies", color: .mint, createdAt: Date()),
            FavoriteList(id: FavoriteListID("l2"), name: "Drama", color: .indigo, createdAt: Date())
        ])

        return FavoriteListBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            favoriteListsStateUseCase: { favoriteListsUseCases.lists },
            favoriteListsSequenceUseCase: { favoriteListsUseCases.listsSequence },
            refreshFavoriteListsUseCase: { try await favoriteListsUseCases.refresh() },
            router: router,
            authButtonBuilder: AuthButtonBuilder.preview()
        )
    }
}
