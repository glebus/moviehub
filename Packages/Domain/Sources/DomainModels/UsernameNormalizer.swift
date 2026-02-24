import Foundation

public enum UsernameNormalizer {
    public static func normalize(_ username: String) -> String {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = trimmed.lowercased()
        let collapsed = lowercased.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
        return collapsed
    }
}
