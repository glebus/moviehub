import SwiftUI
import DomainModels
import DomainUseCases
import Coordinator
import AuthButton

public struct FavoriteListScreen: View {
    @State var viewModel: FavoriteListViewModel

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
                        Text("No lists")
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
        .navigationTitle("Lists")
        .onAppear {
            viewModel.onAppear()
        }
        .toolbar {
            viewModel.authButtonBuilder.build()
        }
    }
}

#Preview {
    FavoriteListBuilder.preview().build()
}
