import SwiftUI
import DomainModels
import DomainUseCases
import Coordinator
import DomainMocks

@MainActor
public struct AuthBuilder {
    private let loginUseCase: LoginAction
    private let coordinator: any CoordinatorProtocol

    public init(loginUseCase: @escaping LoginAction, coordinator: any CoordinatorProtocol) {
        self.loginUseCase = loginUseCase
        self.coordinator = coordinator
    }

    public func build() -> some View {
        let viewModel = AuthViewModel(loginUseCase: loginUseCase, coordinator: coordinator)
        return AuthScreen(viewModel: viewModel)
    }

    public static func preview() -> AuthBuilder {
        let coordinator = CoordinatorMock()
        let session = SessionUseCaseMock()
        return AuthBuilder(loginUseCase: { try await session.login(username: $0) }, coordinator: coordinator)
    }
}
