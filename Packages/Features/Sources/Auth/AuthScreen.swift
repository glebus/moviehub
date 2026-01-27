import SwiftUI

public struct AuthScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: AuthViewModel

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Username")
                    .font(.headline)

                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()

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

                Spacer(minLength: 0)
            }
            .frame(maxWidth: 480, alignment: .leading)
            .padding()
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

#Preview {
    AuthBuilder.preview().build()
}
