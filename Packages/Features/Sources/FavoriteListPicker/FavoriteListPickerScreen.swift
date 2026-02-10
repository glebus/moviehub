import SwiftUI
import Domain
import Router
import AuthButton

public struct FavoriteListPickerScreen: View {
    @State var viewModel: FavoriteListPickerViewModel

    public var body: some View {
        Group {
            if viewModel.currentUser == nil {
                VStack {
                    Text("Not logged in")
                        .font(.headline)
                }
            } else {
                if viewModel.lists.isEmpty {
                    VStack {
                        Text("No lists yet")
                            .font(.headline)
                    }
                } else {
                    List(viewModel.lists, id: \.id) { list in
                        Button {
                            viewModel.select(listId: list.id)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(list.color.uiColor)
                                    .frame(width: 14, height: 14)
                                Text(list.name)
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Pick a List")
        .onAppear {
            viewModel.onAppear()
        }
        .toolbar {
            viewModel.authButtonBuilder.build()
        }
        .alert("Couldn't add favorite", isPresented: Binding(
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
