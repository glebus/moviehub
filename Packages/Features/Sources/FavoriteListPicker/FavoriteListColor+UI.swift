import SwiftUI
import DomainModels
import DomainUseCases

extension FavoriteListColor {
    var uiColor: Color {
        switch self {
        case .coral:
            return .orange
        case .amber:
            return .yellow
        case .olive:
            return .green
        case .mint:
            return .mint
        case .teal:
            return .teal
        case .sky:
            return .blue
        case .indigo:
            return .indigo
        case .slate:
            return .gray
        }
    }
}
