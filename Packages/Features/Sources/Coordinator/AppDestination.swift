import DomainModels

public enum AppDestination: Hashable, Sendable {
    case movieDetails(MovieID)
    case favoriteListDetails(FavoriteListID)
    case favoriteListAddMovies(FavoriteListAddMoviesRequest)
    case auth
    case favoriteListPicker(MovieDetails)
    case favoriteListCreate(movieToAdd: MovieDetails?)
}

public enum PresentationStyle: Hashable, Sendable {
    case sheet
    case fullScreenCover
}

public enum AppTab: Hashable, CaseIterable, Sendable {
    case home
    case favorites
    case profile
}

public struct FavoriteListAddMoviesRequest: Hashable, Sendable {
    public let listId: FavoriteListID
    public let listName: String
    public let initialQuery: String

    public init(
        listId: FavoriteListID,
        listName: String,
        initialQuery: String
    ) {
        self.listId = listId
        self.listName = listName
        self.initialQuery = initialQuery
    }
}
