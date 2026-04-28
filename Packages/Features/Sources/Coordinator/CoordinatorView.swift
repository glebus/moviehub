import SwiftUI

public struct CoordinatorView: View {
    @Bindable private var coordinator: Coordinator

    public init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }

    @ViewBuilder
    public var body: some View {
        #if os(iOS)
        modalContent
            .fullScreenCover(item: fullScreenBinding) { child in
                CoordinatorView(coordinator: child)
            }
        #else
        modalContent
        #endif
    }

    private var modalContent: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.builder(coordinator.destination, coordinator)
                .navigationDestination(for: AppDestination.self) { destination in
                    coordinator.builder(destination, coordinator)
                }
        }
        .sheet(item: sheetBinding) { child in
            CoordinatorView(coordinator: child)
        }
    }

    private var sheetBinding: Binding<Coordinator?> {
        Binding(
            get: { coordinator.presented?.style == .sheet ? coordinator.presented : nil },
            set: { newValue in if newValue == nil { coordinator.presented = nil } }
        )
    }

    private var fullScreenBinding: Binding<Coordinator?> {
        Binding(
            get: {
                coordinator.presented?.style == .fullScreenCover
                    ? coordinator.presented
                    : nil
            },
            set: { newValue in if newValue == nil { coordinator.presented = nil } }
        )
    }
}
