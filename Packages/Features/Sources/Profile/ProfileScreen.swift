import SwiftUI
import Domain
import Router
import DomainMocks

public struct ProfileScreen: View {
    @State var viewModel: ProfileViewModel

    public var body: some View {
        VStack {
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
    }
}

#Preview {
    ProfileBuilder.preview().build()
}
