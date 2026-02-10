import SwiftUI

public struct FavoriteListCreateCoordinator: View {
    @Bindable var viewModel: FavoriteListCreateViewModel

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            FavoriteListNameScreen(viewModel: viewModel)
                .navigationDestination(for: FavoriteListCreateStep.self) { step in
                    switch step {
                    case .color:
                        FavoriteListColorScreen(viewModel: viewModel)
                    }
                }
        }
    }
}
