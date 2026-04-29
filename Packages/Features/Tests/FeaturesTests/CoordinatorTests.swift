import SwiftUI
import Testing
import Coordinator

@MainActor
struct CoordinatorTests {
    private let builder: CoordinatorBuilder = { _, _ in AnyView(EmptyView()) }

    @Test
    func tabChildPushMutatesOnlyScopedTabPath() {
        let coordinator = TabCoordinator(builder: builder)

        coordinator.child(for: .home).push(AppDestination.auth)

        #expect(!coordinator.path(for: .home).isEmpty)
        #expect(coordinator.path(for: .favorites).isEmpty)
        #expect(coordinator.path(for: .profile).isEmpty)
    }

    @Test
    func rootPresentationCreatesModalCoordinator() {
        let coordinator = TabCoordinator(builder: builder)

        coordinator.present(.auth)

        #expect(coordinator.presented?.destination == .auth)
        #expect(coordinator.presented?.style == .sheet)
    }

    @Test
    func modalDismissRemovesChildFromParent() {
        let coordinator = TabCoordinator(builder: builder)
        coordinator.present(.auth)

        coordinator.presented?.dismiss()

        #expect(coordinator.presented == nil)
    }

    @Test
    func dismissAndPresentReplacesCurrentModalAtParentLevel() {
        let coordinator = TabCoordinator(builder: builder)
        coordinator.present(.auth)

        coordinator.presented?.dismissAndPresent(.favoriteListCreate(movieToAdd: nil))

        #expect(coordinator.presented?.destination == .favoriteListCreate(movieToAdd: nil))
        #expect(coordinator.presented?.style == .sheet)
    }

    @Test
    func prepareForPresentClearsModalAndCallsEveryTabDelegate() async {
        let coordinator = TabCoordinator(builder: builder)
        let homeDelegate = Delegate()
        let favoritesDelegate = Delegate()
        let profileDelegate = Delegate()
        coordinator.child(for: .home).delegate = homeDelegate
        coordinator.child(for: .favorites).delegate = favoritesDelegate
        coordinator.child(for: .profile).delegate = profileDelegate
        coordinator.present(.auth)

        await coordinator.prepareForPresent()

        #expect(coordinator.presented == nil)
        #expect(homeDelegate.prepareForPresentCalled)
        #expect(favoritesDelegate.prepareForPresentCalled)
        #expect(profileDelegate.prepareForPresentCalled)
    }
}

@MainActor
private final class Delegate: CoordinatorDelegate {
    var prepareForPresentCalled = false

    func prepareForPresent() async {
        prepareForPresentCalled = true
    }
}
