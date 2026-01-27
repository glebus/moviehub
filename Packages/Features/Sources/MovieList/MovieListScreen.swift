import SwiftUI
import Domain
import Router
import DomainMocks

public struct MovieListScreen: View {
    @State var viewModel: MovieListViewModel

    public var body: some View {
        VStack(spacing: 16) {
            SearchBarView(text: $viewModel.searchText) {
                viewModel.submitSearch()
            }

            switch viewModel.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded(let movies):
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                        ForEach(movies) { movie in
                            Button {
                                viewModel.select(movieId: movie.id)
                            } label: {
                                MovieTileView(movie: movie)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            case .error(let message):
                VStack {
                    Spacer()
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                    Spacer()
                }
            }
        }
        .padding()
        .navigationTitle("Movies")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(viewModel.profileButtonTitle) {
                    viewModel.profileButtonTapped()
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    MovieListBuilder.preview().build()
}
