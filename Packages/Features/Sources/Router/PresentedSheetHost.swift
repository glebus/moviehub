import SwiftUI

public struct PresentedSheetHost<Root: View, Destination: View>: View {
    @Bindable private var router: PresentedSheetRouter
    private let root: Root
    private let destinationBuilder: (AppPushDestination) -> Destination

    public init(
        router: PresentedSheetRouter,
        @ViewBuilder root: () -> Root,
        @ViewBuilder destinationBuilder: @escaping (AppPushDestination) -> Destination
    ) {
        self.router = router
        self.root = root()
        self.destinationBuilder = destinationBuilder
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            root
                .navigationDestination(for: AppDestination<AppPushDestination>.self) { destination in
                    destinationBuilder(destination.value)
                }
        }
    }
}
