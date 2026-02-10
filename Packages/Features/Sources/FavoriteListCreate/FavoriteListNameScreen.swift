import SwiftUI

struct FavoriteListNameScreen: View {
    @Bindable var viewModel: FavoriteListCreateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Name your list")
                .font(.title2.weight(.semibold))

            TextField("List name", text: $viewModel.listName)
                .textFieldStyle(.roundedBorder)

            Spacer()

            Button("Next") {
                viewModel.nextTapped()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .navigationTitle("New List")
        .alert("Couldn't create list", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
