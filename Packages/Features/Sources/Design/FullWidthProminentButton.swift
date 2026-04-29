import SwiftUI

public struct FullWidthButton: View {
    private let title: LocalizedStringKey
    private let action: () -> Void

    public init(
        _ title: LocalizedStringKey,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
    }
}
