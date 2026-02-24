import SwiftUI
import DomainModels
import DomainUseCases
import Router
import DomainMocks

@MainActor
public struct AuthButtonBuilder {
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let router: AppRouterProtocol

    public init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        router: AppRouterProtocol
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.router = router
    }

    public func build() -> some ToolbarContent {
        let viewModel = AuthButtonViewModel(
            currentUserUseCase: currentUserUseCase,
            currentUserSequenceUseCase: currentUserSequenceUseCase,
            router: router
        )
        return AuthButton(viewModel: viewModel)
    }

    public static func preview() -> AuthButtonBuilder {
        let router = AppRouterMock()
        let session = SessionUseCaseMock()
        return AuthButtonBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            router: router
        )
    }
}
