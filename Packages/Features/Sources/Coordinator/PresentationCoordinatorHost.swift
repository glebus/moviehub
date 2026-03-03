import SwiftUI

public struct PresentationCoordinatorHost<Root: View, Destination: View>: View {
    @Bindable private var coordinator: PresentationCoordinator
    private let root: Root
    private let destinationBuilder: (AppPushDestination) -> Destination
    private let presentationCoordinatorBuilder: ((PresentationCoordinator) -> AnyView)?

    public init(
        coordinator: PresentationCoordinator,
        @ViewBuilder root: () -> Root,
        @ViewBuilder destinationBuilder: @escaping (AppPushDestination) -> Destination,
        presentationCoordinatorBuilder: ((PresentationCoordinator) -> AnyView)? = nil
    ) {
        self.coordinator = coordinator
        self.root = root()
        self.destinationBuilder = destinationBuilder
        self.presentationCoordinatorBuilder = presentationCoordinatorBuilder
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            root
                .navigationDestination(for: AppDestination<AppPushDestination>.self) { destination in
                    destinationBuilder(destination.value)
                }
        }
        .modifier(PresentationCoordinatorModifier(
            coordinator: coordinator,
            coordinatorBuilder: presentationCoordinatorBuilder
        ))
    }
}

struct PresentationCoordinatorModifier: ViewModifier {
    @Bindable var coordinator: PresentationCoordinator
    let coordinatorBuilder: ((PresentationCoordinator) -> AnyView)?

    func body(content: Content) -> some View {
        if let coordinatorBuilder {
            content
                .sheet(item: sheetBinding) { childCoordinator in
                    coordinatorBuilder(childCoordinator)
                }
                .fullScreenCover(item: fullScreenBinding) { childCoordinator in
                    coordinatorBuilder(childCoordinator)
                }
        } else {
            content
        }
    }

    private var sheetBinding: Binding<PresentationCoordinator?> {
        Binding(
            get: {
                coordinator.presentationCoordinator?.style == .sheet
                    ? coordinator.presentationCoordinator
                    : nil
            },
            set: { newValue in
                if newValue == nil { coordinator.presentationCoordinator = nil }
            }
        )
    }

    private var fullScreenBinding: Binding<PresentationCoordinator?> {
        Binding(
            get: {
                coordinator.presentationCoordinator?.style == .fullScreenCover
                    ? coordinator.presentationCoordinator
                    : nil
            },
            set: { newValue in
                if newValue == nil { coordinator.presentationCoordinator = nil }
            }
        )
    }
}
