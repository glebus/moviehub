import SwiftUI
import Domain
import Router
import AuthButton

public struct FavoriteListScreen: View {
    @State var viewModel: FavoriteListViewModel

    public var body: some View {
        Group {
            if viewModel.currentUser == nil {
                VStack {
                    Text("Not logged in")
                        .font(.headline)
                }
            } else {
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
        }
        .navigationTitle("Favorites")
        .onAppear {
            viewModel.onAppear()
        }
        .toolbar {
            viewModel.authButtonBuilder.build()
        }
    }
}

#Preview {
    FavoriteListBuilder.preview().build()
}
