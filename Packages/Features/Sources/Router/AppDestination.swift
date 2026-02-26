import DomainModels
import DomainUseCases

public struct AppDestination<Value: Hashable & Sendable>: Identifiable, Equatable, Hashable, Sendable {
    public let value: Value
    public var id: Int { value.hashValue }

    public init(value: Value) {
        self.value = value
    }
}

public enum AppPushDestination: Hashable, Sendable {
    case movieDetails(MovieID)
    case favoriteListDetails(FavoriteListID)
    case favoriteListAddMovies(FavoriteListAddMoviesRequest)
}

public enum AppSheetDestination: Hashable, Sendable {
    case auth
    case favoriteListPicker(MovieDetails)
    case favoriteListCreate
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
