import SwiftUI
import DomainModels

struct FavoriteListAddMoviesRowView: View {
    let movie: Movie
    @Binding var isOn: Bool
    let isUpdating: Bool

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    ZStack { Color.secondary.opacity(0.1); ProgressView() }
                case .failure:
                    ZStack { Color.secondary.opacity(0.1); Image(systemName: "film") }
                @unknown default:
                    Color.secondary.opacity(0.1)
                }
            }
            .frame(width: 44, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                if let year = movie.year {
                    Text(year)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if isUpdating {
                ProgressView()
                    .controlSize(.small)
                    .frame(width: 44)
            } else {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        }
    }
}
