import SwiftUI
import Domain
import Router
import DomainMocks

@MainActor
public struct AuthBuilder {
    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol

    public init(sessionInteractor: SessionInteractorProtocol, router: AppRouterProtocol) {
        self.sessionInteractor = sessionInteractor
        self.router = router
    }

    public func build() -> AuthScreen {
        let viewModel = AuthViewModel(sessionInteractor: sessionInteractor, router: router)
        return AuthScreen(viewModel: viewModel)
    }

    public static func preview() -> AuthBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        return AuthBuilder(sessionInteractor: session, router: router)
    }
}
