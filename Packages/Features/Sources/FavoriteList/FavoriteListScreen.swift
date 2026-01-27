import SwiftUI
import Domain
import Router
import DomainMocks

public struct FavoriteListScreen: View {
    @State var viewModel: FavoriteListViewModel

    public var body: some View {
        Group {
            switch viewModel.state {
            case .loggedOut:
                VStack {
                    Text("Not logged in")
                        .font(.headline)
                    Button("Login") {
                        viewModel.loginTapped()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loading:
                ProgressView()
            case .loaded(let favorites):
                List(favorites, id: \.id) { movie in
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
            case .error(let message):
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Favorites")
    }
}

#Preview {
    FavoriteListBuilder.preview().build()
}
