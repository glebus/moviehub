import Foundation
import Domain
import Data

final class AppContainer {
    let movieRepository: MovieRepository
    let swiftDataStorage: SwiftDataStorage
    let sessionInteractor: SessionInteractor
    let favoritesInteractor: FavoritesInteractor

    init() {
        let httpClient = URLSessionHTTPClient()
        self.movieRepository = MovieRepository(
            httpClient: httpClient,
            readAccessToken: Secrets.tmdbReadToken
        )

        let stack = SwiftDataStack(inMemory: false)
        self.swiftDataStorage = SwiftDataStorage(container: stack.container)

        self.sessionInteractor = SessionInteractor(profileRepository: swiftDataStorage)
        self.favoritesInteractor = FavoritesInteractor(
            favoritesRepository: swiftDataStorage,
            sessionInteractor: sessionInteractor
        )
    }
}
