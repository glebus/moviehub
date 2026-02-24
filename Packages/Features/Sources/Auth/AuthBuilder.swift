import SwiftUI
import DomainModels
import DomainUseCases
import Router
import DomainMocks

@MainActor
public struct AuthBuilder {
    private let loginUseCase: LoginAction
    private let router: AppRouterProtocol

    public init(loginUseCase: @escaping LoginAction, router: AppRouterProtocol) {
        self.loginUseCase = loginUseCase
        self.router = router
    }

    public func build() -> some View {
        let viewModel = AuthViewModel(loginUseCase: loginUseCase, router: router)
        return AuthScreen(viewModel: viewModel)
    }

    public static func preview() -> AuthBuilder {
        let router = AppRouterMock()
        let session = SessionUseCaseMock()
        return AuthBuilder(loginUseCase: { try await session.login(username: $0) }, router: router)
    }
}
