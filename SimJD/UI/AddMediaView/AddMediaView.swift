import SwiftUI

struct AddMediaView: View {
    @State private var viewModel: AddMediaViewModel

    init(viewModel: AddMediaViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        listOrVStackView {
            content
        }
        .padding()
        .onDrop(of: [.fileURL, .url], isTargeted: $viewModel.isTargeted) { providers in
            Task {
                let _ = await viewModel.handleDrop(providers)
            }

            return true
        }
    }

    @ViewBuilder
    func listOrVStackView<T: View>(content: () -> T) -> some View {
        VStack {
            content()
        }
        .inCase(viewModel.addedMedia.count + viewModel.failedToAddMedia.count > 20) {
            List {
                content()
            }
            .frame(
                maxWidth: .infinity,
                idealHeight: viewModel.listHeight(),
                maxHeight: .infinity
            )
        }
    }

    @ViewBuilder
    var content: some View {
        VStack {
            Image(systemName: "plus.rectangle.on.folder")
                .font(.headline)
            Text("Drag-and-drop the file")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowSeparator(.hidden, edges: .all)

        Section("Added Media") {
            ForEach(viewModel.addedMedia, id: \.self) { (path: String) in
                Divider()
                LabeledContent(path, value: "✅")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding()
            }
        }
        .listRowSeparator(.hidden, edges: .all)
        .inCase(viewModel.addedMedia.isEmpty) { EmptyView() }

        Section("Failed to Add Media") {
            ForEach(viewModel.failedToAddMedia, id: \.self) { (path: String) in
                LabeledContent(path, value: "❌")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding()
            }
        }
        .listRowSeparator(.hidden, edges: .all)
        .inCase(viewModel.failedToAddMedia.isEmpty) { EmptyView() }
    }
}
