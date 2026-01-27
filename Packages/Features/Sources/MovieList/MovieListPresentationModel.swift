import Foundation
import Domain

public struct MovieTilePresentationModel: Identifiable, Sendable {
    public let id: MovieID
    public let title: String
    public let year: String?
    public let posterURL: URL?

    public init(id: MovieID, title: String, year: String?, posterURL: URL?) {
        self.id = id
        self.title = title
        self.year = year
        self.posterURL = posterURL
    }
}
