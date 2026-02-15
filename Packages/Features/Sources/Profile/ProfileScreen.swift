import SwiftUI
import Domain
import Router
import AuthButton

public struct ProfileScreen: View {
    @State var viewModel: ProfileViewModel

    public var body: some View {
        List {
            Section {
                headerRow
            }

            switch viewModel.state {
            case .loggedIn:
                Section("Lists") {
                    viewModel.favoriteListsManageBuilder.build()
                }
                Section("Account") {
                    Button("Logout") {
                        viewModel.logoutTapped()
                    }
                }
            case .loggedOut:
                Section {
                    Text("Log in to manage your lists and favorites.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.inset)
        #endif
        .navigationTitle("Profile")
        .toolbar {
            viewModel.authButtonBuilder.build()
        }
    }
}

private extension ProfileScreen {
    var headerRow: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(Text(initials).font(.headline))
            VStack(alignment: .leading, spacing: 2) {
                Text(titleText)
                    .font(.headline)
                Text(subtitleText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    var titleText: String {
        switch viewModel.state {
        case .loggedIn(let username):
            return username
        case .loggedOut:
            return "Guest"
        }
    }

    var subtitleText: String {
        switch viewModel.state {
        case .loggedIn:
            return "Signed in"
        case .loggedOut:
            return "Guest account"
        }
    }

    var initials: String {
        switch viewModel.state {
        case .loggedIn(let username):
            return String(username.prefix(2)).uppercased()
        case .loggedOut:
            return "MH"
        }
    }

}

#Preview {
    ProfileBuilder.preview().build()
}
