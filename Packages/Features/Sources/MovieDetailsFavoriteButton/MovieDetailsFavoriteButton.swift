import SwiftUI

struct MovieDetailsFavoriteButton: View {
    @State var viewModel: MovieDetailsFavoriteButtonViewModel

    init(viewModel: MovieDetailsFavoriteButtonViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(viewModel.title) {
                viewModel.tapped()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isEnabled)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }
}
