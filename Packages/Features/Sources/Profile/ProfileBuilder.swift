import SwiftUI
import Domain
import Router
import AuthButton
import DomainMocks

@MainActor
public struct ProfileBuilder {
    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol
    private let authButtonBuilder: AuthButtonBuilder

    public init(
        sessionInteractor: SessionInteractorProtocol,
        router: AppRouterProtocol,
        authButtonBuilder: AuthButtonBuilder
    ) {
        self.sessionInteractor = sessionInteractor
        self.router = router
        self.authButtonBuilder = authButtonBuilder
    }

    public func build() -> ProfileScreen {
        let viewModel = ProfileViewModel(
            sessionInteractor: sessionInteractor,
            router: router,
            authButtonBuilder: authButtonBuilder
        )
        return ProfileScreen(viewModel: viewModel)
    }

    public static func preview() -> ProfileBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        return ProfileBuilder(
            sessionInteractor: session,
            router: router,
            authButtonBuilder: AuthButtonBuilder.preview()
        )
    }
}
