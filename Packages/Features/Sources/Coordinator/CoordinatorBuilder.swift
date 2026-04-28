import SwiftUI

public typealias CoordinatorBuilder = @MainActor (
    AppDestination,
    any CoordinatorProtocol
) -> AnyView
