import SwiftUI
import Domain

public struct AuthDependencies: Sendable {
    public let profileRepository: ProfileRepositoryProtocol

    public init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
}

public struct AuthScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AuthViewModel

    public init(dependencies: AuthDependencies) {
        _viewModel = State(initialValue: AuthViewModel(profileRepository: dependencies.profileRepository))
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            Form {
                Section("Username") {
                    TextField("Username", text: $viewModel.username)
                }

                if case .error(let message) = viewModel.state {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button("Login") {
                    viewModel.loginTapped()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.state == .submitting)
            }
            .navigationTitle("Login")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.state) { _, newValue in
                if case .success = newValue {
                    dismiss()
                }
            }
        }
    }
}
