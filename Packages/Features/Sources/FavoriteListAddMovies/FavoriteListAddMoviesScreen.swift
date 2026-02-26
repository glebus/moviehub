import SwiftUI
import DomainModels

public struct FavoriteListAddMoviesScreen: View {
    @State var viewModel: FavoriteListAddMoviesViewModel

    public var body: some View {
        VStack(spacing: 12) {
            FavoriteListAddMoviesSearchBarView(text: $viewModel.searchText) {
                viewModel.submitSearch()
            }

            if viewModel.isSearching && viewModel.searchResults.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                List(viewModel.searchResults, id: \.id) { movie in
                    FavoriteListAddMoviesRowView(
                        movie: movie,
                        isOn: Binding(
                            get: { viewModel.isSelected(movieId: movie.id) },
                            set: { viewModel.toggle(movieId: movie.id, isOn: $0) }
                        ),
                        isUpdating: viewModel.isUpdating(movieId: movie.id)
                    )
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .navigationTitle(viewModel.listName)
        .toolbar {
            ToolbarItem {
                Button("Done") {
                    viewModel.doneTapped()
                }
            }
        }
        .alert("Couldn't update favorites", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

private struct FavoriteListAddMoviesSearchBarView: View {
    @Binding var text: String
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search", text: $text)
                .textFieldStyle(.plain)
                .onSubmit(onSubmit)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.15))
        )
    }
}
