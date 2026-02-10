import SwiftUI
import Domain

struct FavoriteListColorScreen: View {
    @Bindable var viewModel: FavoriteListCreateViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 64), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pick a color")
                .font(.title2.weight(.semibold))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(FavoriteListColor.allCases, id: \.self) { color in
                    Button {
                        viewModel.selectedColor = color
                    } label: {
                        ZStack {
                            Circle()
                                .fill(color.uiColor)
                                .frame(width: 48, height: 48)
                            if viewModel.selectedColor == color {
                                Circle()
                                    .stroke(.primary, lineWidth: 2)
                                    .frame(width: 56, height: 56)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            Button(viewModel.isSaving ? "Creating..." : "Create list") {
                viewModel.createTapped()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSaving)
        }
        .padding()
        .navigationTitle("List Color")
        .alert("Couldn't create list", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
