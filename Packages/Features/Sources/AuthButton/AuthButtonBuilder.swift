import SwiftUI
import DomainModels
import DomainUseCases
import Coordinator
import DomainMocks

@MainActor
public struct AuthButtonBuilder {
    private let currentUserUseCase: CurrentUserReader
    private let currentUserSequenceUseCase: CurrentUserSequenceSource
    private let coordinator: any CoordinatorProtocol

    public init(
        currentUserUseCase: @escaping CurrentUserReader,
        currentUserSequenceUseCase: @escaping CurrentUserSequenceSource,
        coordinator: any CoordinatorProtocol
    ) {
        self.currentUserUseCase = currentUserUseCase
        self.currentUserSequenceUseCase = currentUserSequenceUseCase
        self.coordinator = coordinator
    }

    public func build() -> some ToolbarContent {
        let viewModel = AuthButtonViewModel(
            currentUserUseCase: currentUserUseCase,
            currentUserSequenceUseCase: currentUserSequenceUseCase,
            coordinator: coordinator
        )
        return AuthButton(viewModel: viewModel)
    }

    public static func preview() -> AuthButtonBuilder {
        let coordinator = CoordinatorMock()
        let session = SessionUseCaseMock()
        return AuthButtonBuilder(
            currentUserUseCase: { session.currentUser },
            currentUserSequenceUseCase: { session.currentUserSequence },
            coordinator: coordinator
        )
    }
}
