import SwiftUI
import Domain
import Router
import DomainMocks

@MainActor
public struct AuthButtonBuilder {
    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol

    public init(sessionInteractor: SessionInteractorProtocol, router: AppRouterProtocol) {
        self.sessionInteractor = sessionInteractor
        self.router = router
    }

    public func build() -> AuthButton {
        let viewModel = AuthButtonViewModel(sessionInteractor: sessionInteractor, router: router)
        return AuthButton(viewModel: viewModel)
    }

    public static func preview() -> AuthButtonBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        return AuthButtonBuilder(sessionInteractor: session, router: router)
    }
}
