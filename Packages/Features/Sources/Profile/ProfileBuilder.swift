import SwiftUI
import Domain
import Router
import DomainMocks

@MainActor
public struct ProfileBuilder {
    private let sessionInteractor: SessionInteractorProtocol
    private let router: AppRouterProtocol

    public init(sessionInteractor: SessionInteractorProtocol, router: AppRouterProtocol) {
        self.sessionInteractor = sessionInteractor
        self.router = router
    }

    public func build() -> ProfileScreen {
        let viewModel = ProfileViewModel(sessionInteractor: sessionInteractor, router: router)
        return ProfileScreen(viewModel: viewModel)
    }

    public static func preview() -> ProfileBuilder {
        let router = AppRouterMock()
        let session = SessionInteractorMock()
        return ProfileBuilder(sessionInteractor: session, router: router)
    }
}
