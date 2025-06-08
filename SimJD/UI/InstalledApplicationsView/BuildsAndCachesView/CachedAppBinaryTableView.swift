//
//  CachedAppBinaryTableView.swift
//  SimJD
//
//  Created by John Demirci on 6/4/25.
//

import SwiftUI

struct CachedAppBinaryTableView: View {
    enum Event {
        case didSelectCachedFolder(Set<FileItem.ID>)
    }

    @Binding var items: [FileItem]?
    @State private var selection: FileItem.ID?
    
    let sendEvent: (Event) -> Void

    var body: some View {
        OptionalView(items) { (fileItems: [FileItem]) in
            Section {
                Table(fileItems, selection: $selection) {
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
                .alternatingRowBackgrounds(.disabled)
                .contextMenu(
                    forSelectionType: FileItem.ID.self,
                    menu: { _ in EmptyView() },
                    primaryAction: { (selectedIDs: Set<FileItem.ID>) in
                        sendEvent(.didSelectCachedFolder(selectedIDs))
                    }
                )
                .scrollDisabled(true)
                .frame(height: CGFloat(fileItems.count) * 50 + 50)
            }
        }
    }
}
