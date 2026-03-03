import SwiftUI

public struct PresentedRouteHost<Root: View, Destination: View>: View {
    @Bindable private var router: PresentedRouteRouter
    private let root: Root
    private let destinationBuilder: (AppPushDestination) -> Destination
    private let presentedRouteBuilder: ((PresentedRoutePresentation) -> AnyView)?

    public init(
        router: PresentedRouteRouter,
        @ViewBuilder root: () -> Root,
        @ViewBuilder destinationBuilder: @escaping (AppPushDestination) -> Destination,
        presentedRouteBuilder: ((PresentedRoutePresentation) -> AnyView)? = nil
    ) {
        self.router = router
        self.root = root()
        self.destinationBuilder = destinationBuilder
        self.presentedRouteBuilder = presentedRouteBuilder
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            root
                .navigationDestination(for: AppDestination<AppPushDestination>.self) { destination in
                    destinationBuilder(destination.value)
                }
        }
        .modifier(PresentedRouteModifier(router: router, routeBuilder: presentedRouteBuilder))
    }
}

struct PresentedRouteModifier: ViewModifier {
    @Bindable var router: PresentedRouteRouter
    let routeBuilder: ((PresentedRoutePresentation) -> AnyView)?

    func body(content: Content) -> some View {
        if let routeBuilder {
            content
                .sheet(item: sheetBinding) { presentation in
                    routeBuilder(presentation)
                }
                .fullScreenCover(item: fullScreenBinding) { presentation in
                    routeBuilder(presentation)
                }
        } else {
            content
        }
    }

    private var sheetBinding: Binding<PresentedRoutePresentation?> {
        Binding(
            get: { router.presentedRoute?.style == .sheet ? router.presentedRoute : nil },
            set: { newValue in
                if newValue == nil { router.presentedRoute = nil }
            }
        )
    }

    private var fullScreenBinding: Binding<PresentedRoutePresentation?> {
        Binding(
            get: { router.presentedRoute?.style == .fullScreenCover ? router.presentedRoute : nil },
            set: { newValue in
                if newValue == nil { router.presentedRoute = nil }
            }
        )
    }
}
