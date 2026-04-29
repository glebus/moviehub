import SwiftUI
import DomainModels
import DomainUseCases
import Coordinator

public struct FavoriteListDetailsScreen: View {
    @State var viewModel: FavoriteListDetailsViewModel

    public var body: some View {
        Group {
            if viewModel.favorites.isEmpty {
                VStack {
                    Text("No favorites")
                        .font(.headline)
                }
            } else {
                List(viewModel.favorites, id: \.id) { movie in
                    Button {
                        viewModel.select(movieId: movie.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(movie.title)
                                .font(.headline)
                            if let year = movie.year {
                                Text(year)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle(viewModel.listName)
        .onAppear {
            viewModel.onAppear()
        }
        .toolbar {
            Button {
                viewModel.addMovieTapped()
            } label: {
                Label("Add Movie", systemImage: "plus")
            }
        }
    }
}
