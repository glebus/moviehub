import SwiftUI

struct MovieTileView: View {
    let movie: MovieTilePresentationModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(Color.secondary.opacity(0.1))
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
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
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(movie.title)
                .font(.headline)
                .lineLimit(2)

            if let year = movie.year {
                Text(year)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
