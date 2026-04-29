import SwiftUI
import DomainModels
import Design

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

            VStack(spacing: 12) {
                if let movieToAdd = viewModel.movieToAdd {
                    FullWidthButton(LocalizedStringKey("Add \(movieToAdd.title)")) {
                        viewModel.addCreatedMovieTapped(list: list)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isAddingMovieToCreatedList)
                }

                if viewModel.movieToAdd == nil {
                    FullWidthButton("Add Movies") {
                        viewModel.addMoviesTapped(list: list)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    FullWidthButton("Add Movies") {
                        viewModel.addMoviesTapped(list: list)
                    }
                    .buttonStyle(.bordered)
                }

                FullWidthButton("Close") {
                    viewModel.closeTapped()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationTitle("New List")
        .alert("Couldn't add movie", isPresented: Binding(
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
