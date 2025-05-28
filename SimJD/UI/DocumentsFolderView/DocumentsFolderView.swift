//
//  DocumentsFolderView.swift
//  SimJD
//
//  Created by John Demirci on 4/14/25.
//

import SwiftUI

struct DocumentsFolderView: View {
    @State private var viewModel: DocumentsFolderViewModel

    init(viewModel: DocumentsFolderViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Table(viewModel.items, selection: $viewModel.selectedItem) {
            TableColumn("Name") { (item: FileItem) in
                HStack {
                    FileIconView(url: item.url)
                    Text(item.name)
                }
            }

            TableColumn("Creation Date") { (item: FileItem) in
                Text("\(item.creationDate?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
            }

            TableColumn("Last Modified") { (item: FileItem) in
                Text("\(item.modificationDate?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
            }

            TableColumn("Type") { (item: FileItem) in
                Text(item.contentType ?? "N/A")
            }

            TableColumn("Size") { (item: FileItem) in
                if let size = item.size {
                    Text(size, format: .number)
                } else {
                    Text("N/A")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .contextMenu(
            forSelectionType: FileItem.ID.self,
            menu: { (selectedItems: Set<FileItem.ID>) in
                Button("Open") {
                    if selectedItems.count == 1 {
                        viewModel.selectedItem = selectedItems.first
                    }
                    viewModel.didDoubleClickOn(selectedItems)
                }

                Button("Copy Path") {
                    viewModel.didSelectCopyPathToClipboard(selectedItems)
                }

                Button("Open in Finder") {
                    viewModel.didSelectOpenInFinder(selectedItems)
                }
            },
            primaryAction: { (selectedItems: Set<FileItem.ID>) in
                viewModel.didDoubleClickOn(selectedItems)
            }
        )
        .onAppear {
            viewModel.fetchFileItems()
        }
    }
}
