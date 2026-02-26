import Foundation
import DomainModels
import DomainUseCases
import Data

final class AppContainer {
    let movieRepository: MovieRepository
    let swiftDataStorage: SwiftDataStorage
    let profileRepository: SessionRepository
    let favoriteListsRepository: FavoriteListsRepository
    let favoritesRepository: FavoritesRepository
    let loginUseCase: LoginUseCase
    let logoutUseCase: LogoutUseCase
    let refreshFavoriteListsUseCase: RefreshFavoriteListsUseCase
    let createFavoriteListUseCase: CreateFavoriteListUseCase
    let renameFavoriteListUseCase: RenameFavoriteListUseCase
    let deleteFavoriteListUseCase: DeleteFavoriteListUseCase
    let refreshFavoritesUseCase: RefreshFavoritesUseCase
    let addFavoriteUseCase: AddFavoriteUseCase
    let removeFavoriteUseCase: RemoveFavoriteUseCase
    let removeFavoriteFromListUseCase: RemoveFavoriteFromListUseCase
    let lookupFavoriteListsUseCase: LookupFavoriteListsUseCase
    let handleMovieDetailsFavoriteTapUseCase: HandleMovieDetailsFavoriteTapUseCase

    init() {
        let httpClient = URLSessionHTTPClient()
        self.movieRepository = MovieRepository(
            httpClient: httpClient,
            readAccessToken: Secrets.tmdbReadToken
        )

        let stack = SwiftDataStack(inMemory: false)
        self.swiftDataStorage = SwiftDataStorage(container: stack.container)
        self.profileRepository = SessionRepository(storage: swiftDataStorage)
        self.favoriteListsRepository = FavoriteListsRepository(storage: swiftDataStorage)
        self.favoritesRepository = FavoritesRepository(storage: swiftDataStorage)

        self.loginUseCase = LoginUseCase(
            profileRepository: profileRepository,
            favoriteListsRepository: favoriteListsRepository,
            favoritesRepository: favoritesRepository
        )
        self.logoutUseCase = LogoutUseCase(
            profileRepository: profileRepository,
            favoriteListsRepository: favoriteListsRepository,
            favoritesRepository: favoritesRepository
        )
        self.refreshFavoriteListsUseCase = RefreshFavoriteListsUseCase(
            listsRepository: favoriteListsRepository,
            profileRepository: profileRepository
        )
        self.createFavoriteListUseCase = CreateFavoriteListUseCase(
            listsRepository: favoriteListsRepository,
            profileRepository: profileRepository
        )
        self.renameFavoriteListUseCase = RenameFavoriteListUseCase(
            listsRepository: favoriteListsRepository,
            profileRepository: profileRepository
        )
        self.deleteFavoriteListUseCase = DeleteFavoriteListUseCase(
            listsRepository: favoriteListsRepository,
            profileRepository: profileRepository
        )
        self.refreshFavoritesUseCase = RefreshFavoritesUseCase(
            favoritesRepository: favoritesRepository,
            profileRepository: profileRepository
        )
        self.addFavoriteUseCase = AddFavoriteUseCase(
            favoritesRepository: favoritesRepository,
            profileRepository: profileRepository
        )
        self.removeFavoriteUseCase = RemoveFavoriteUseCase(
            favoritesRepository: favoritesRepository,
            profileRepository: profileRepository
        )
        self.removeFavoriteFromListUseCase = RemoveFavoriteFromListUseCase(
            favoritesRepository: favoritesRepository,
            profileRepository: profileRepository
        )
        self.lookupFavoriteListsUseCase = LookupFavoriteListsUseCase(
            favoritesRepository: favoritesRepository,
            profileRepository: profileRepository
        )
        self.handleMovieDetailsFavoriteTapUseCase = HandleMovieDetailsFavoriteTapUseCase(
            profileRepository: profileRepository,
            favoriteListsRepository: favoriteListsRepository,
            favoritesRepository: favoritesRepository
        )
    }
}
