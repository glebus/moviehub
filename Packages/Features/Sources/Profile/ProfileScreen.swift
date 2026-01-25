import SwiftUI
import Domain

public struct ProfileDependencies: Sendable {
    public let sessionInteractor: SessionInteractor
    public let makeAuthScreen: @MainActor () -> AnyView

    public init(
        sessionInteractor: SessionInteractor,
        makeAuthScreen: @escaping @MainActor () -> AnyView
    ) {
        self.sessionInteractor = sessionInteractor
        self.makeAuthScreen = makeAuthScreen
    }
}

public struct ProfileScreen: View {
    @State private var viewModel: ProfileViewModel
    private let dependencies: ProfileDependencies

    public init(dependencies: ProfileDependencies) {
        self.dependencies = dependencies
        _viewModel = State(
            initialValue: ProfileViewModel(sessionInteractor: dependencies.sessionInteractor)
        )
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 16) {
                switch viewModel.state {
                case .loggedIn(let username):
                    Text(username)
                        .font(.title2)

                    Button("Logout") {
                        viewModel.logoutTapped()
                    }
                    .buttonStyle(.bordered)
                case .loggedOut:
                    Text("Not logged in")
                        .font(.headline)
                    Button("Login") {
                        viewModel.loginTapped()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Profile")
            .sheet(isPresented: $viewModel.isAuthSheetPresented) {
                dependencies.makeAuthScreen()
            }
        }
    }
}
