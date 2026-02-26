import SwiftUI
import DomainModels

struct FavoriteListCreatedScreen: View {
    @Bindable var viewModel: FavoriteListCreateViewModel
    let list: FavoriteList

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("List created")
                .font(.title2.weight(.semibold))

            Text("\"\(list.name)\" is ready.")
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 12) {
                Button("Close") {
                    viewModel.closeTapped()
                }
                .buttonStyle(.bordered)

                Button("Add Movies") {
                    viewModel.addMoviesTapped(list: list)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("New List")
    }
}
