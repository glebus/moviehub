import SwiftUI
import Domain
import Router
import AuthButton

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
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Profile")
        .toolbar {
            viewModel.authButtonBuilder.build()
        }
    }
}

#Preview {
    ProfileBuilder.preview().build()
}
