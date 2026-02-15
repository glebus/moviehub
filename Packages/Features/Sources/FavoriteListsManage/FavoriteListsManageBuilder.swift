import SwiftUI
import Domain
import Router

@MainActor
public struct FavoriteListsManageBuilder {
    private let sessionInteractor: SessionInteractorProtocol
    private let favoriteListsInteractor: FavoriteListsInteractorProtocol
    private let router: AppRouterProtocol

    public init(
        sessionInteractor: SessionInteractorProtocol,
        favoriteListsInteractor: FavoriteListsInteractorProtocol,
        router: AppRouterProtocol
    ) {
        self.sessionInteractor = sessionInteractor
        self.favoriteListsInteractor = favoriteListsInteractor
        self.router = router
    }

    public func build() -> some View {
        let viewModel = FavoriteListsManageViewModel(
            sessionInteractor: sessionInteractor,
            favoriteListsInteractor: favoriteListsInteractor,
            router: router
        )
        return FavoriteListsManageScreen(viewModel: viewModel)
    }
}
