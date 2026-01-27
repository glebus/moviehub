import Foundation

enum Secrets {
    static var tmdbReadToken: String {
        guard
            let token = Bundle.main.object(forInfoDictionaryKey: "TMDB_READ_TOKEN") as? String,
            !token.isEmpty
        else {
            fatalError("TMDB_READ_TOKEN is missing. Create Secrets.xcconfig.")
        }
        return token
    }
}
