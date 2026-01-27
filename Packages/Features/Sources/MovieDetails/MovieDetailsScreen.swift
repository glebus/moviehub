import SwiftUI
import Domain
import Router
import AuthButton

public struct MovieDetailsScreen: View {
    @State var viewModel: MovieDetailsViewModel

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch viewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                case .loaded(let model):
                    AsyncImage(url: model.posterURL) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Rectangle().fill(Color.secondary.opacity(0.1))
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            ZStack {
                                Rectangle().fill(Color.secondary.opacity(0.1))
                                Image(systemName: "film")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        @unknown default:
                            Rectangle().fill(Color.secondary.opacity(0.1))
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(model.title)
                            .font(.title2)
                            .bold()

                        if !model.genresText.isEmpty {
                            Text(model.genresText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if let overview = model.overview {
                            Text(overview)
                                .font(.body)
                        }
                    }

                    Button(viewModel.favoriteButtonTitle) {
                        viewModel.favoriteButtonTapped()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.favoriteButtonEnabled)
                case .error(let message):
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .toolbar {
            viewModel.authButtonBuilder.build()
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    MovieDetailsBuilder.preview().build(movieId: MovieID("m1"))
}
