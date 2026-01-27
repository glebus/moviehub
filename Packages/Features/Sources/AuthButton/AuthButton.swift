import SwiftUI

public struct AuthButton: ToolbarContent {
    @State var viewModel: AuthButtonViewModel

    public var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(viewModel.title) {
                viewModel.tapped()
            }
        }
    }
}
