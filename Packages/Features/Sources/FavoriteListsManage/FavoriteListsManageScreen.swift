import SwiftUI
import Domain

public struct FavoriteListsManageScreen: View {
    @State var viewModel: FavoriteListsManageViewModel
    @State private var renameList: FavoriteList?
    @State private var renameName: String = ""

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Lists")
                    .font(.headline)
                Spacer()
                Button("Add") {
                    viewModel.addTapped()
                }
            }

            if viewModel.currentUser == nil {
                Text("Log in to manage lists.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if viewModel.lists.isEmpty {
                Text("No lists yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(viewModel.lists, id: \.id) { list in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(list.color.uiColor)
                                .frame(width: 12, height: 12)
                            Text(list.name)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.delete(listId: list.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                renameList = list
                                renameName = list.name
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .alert("Rename list", isPresented: Binding(
            get: { renameList != nil },
            set: { if !$0 { renameList = nil } }
        )) {
            TextField("Name", text: $renameName)
            Button("Save") {
                if let list = renameList {
                    viewModel.rename(listId: list.id, name: renameName)
                }
                renameList = nil
            }
            Button("Cancel", role: .cancel) {
                renameList = nil
            }
        }
        .alert("Couldn't update list", isPresented: Binding(
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
