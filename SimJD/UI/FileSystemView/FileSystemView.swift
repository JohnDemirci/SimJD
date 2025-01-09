//
//  FileSystemView.swift
//  SimJD
//
//  Created by John Demirci on 12/30/24.
//

import SwiftUI

struct FileSystemView: View {
    enum Event {
        case didFailToFetchFiles
        case didFailToFindSelectedFile
        case didFailToOpenFile
    }

    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var navigator: FileSystemNavigator

    @State private var items: [FileItem] = []
    @State private var selection: FileItem.ID?

    private let currentURL: URL
    private let sendEvent: (Event) -> Void

    var selectedColor: Color {
        colorScheme == .light ? Color.init(nsColor: .brown).opacity(0.2) :
            Color.init(nsColor: .systemBrown)
    }

    init(
        currentURL: URL,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.currentURL = currentURL
        self.sendEvent = sendEvent
    }

    var body: some View {
        Table(items, selection: $selection) {
            TableColumn("Name") { item in
                HStack {
                    FileIconView(url: item.url)
                    Text(item.name)
                }
            }

            TableColumn("Creation Date") { item in
                Text("\(item.creationDate?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
            }

            TableColumn("Last Modified") { item in
                Text("\(item.modificationDate?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
            }

            TableColumn("Size") { item in
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
            menu: { selectedItems in
                Button("Open") {
                    if selectedItems.count == 1 {
                        selection = selectedItems.first
                    }
                    openAction()
                }

                Button("Copy Path") {
                    guard let selectedItem = selectedItems.first else { return }
                    guard let item = items.first(where: { fileItem in
                        fileItem.id == selectedItem
                    }) else { return }

                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(item.url.absoluteString, forType: .string)
                }

                Button("Open in Finder") {
                    guard let selectedItem = selectedItems.first else { return }
                    guard let item = items.first(where: { fileItem in
                        fileItem.id == selectedItem
                    }) else { return }

                    if item.isDirectory {
                        NSWorkspace.shared.open(item.url)
                    }
                }
            },
            primaryAction: { selectedItems in
                if selectedItems.count == 1 {
                    if selection != selectedItems.first {
                        selection = selectedItems.first
                    }
                }

                openAction()
            }
        )
        .onAppear {
            fetchFiles(in: currentURL)
        }
    }

    func openAction() {
        guard let item = self.items.first(where: { fileItem in
            fileItem.id == selection
        }) else {
            sendEvent(.didFailToFindSelectedFile)
            return
        }

        if item.isDirectory {
            withAnimation {
                navigator.add(.fileSystem(url: item.url))
            }
        } else {
            if !NSWorkspace.shared.open(item.url) {
                sendEvent(.didFailToOpenFile)
            }
        }
    }
}

extension FileSystemView {
    func fetchFiles(in url: URL) {
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            let items = fileURLs.compactMap { url -> FileItem? in
                guard let resourceValues = try? url.resourceValues(forKeys: [
                    .isDirectoryKey,
                    .creationDateKey,
                    .contentModificationDateKey,
                    .totalFileSizeKey
                ]
                ) else { return nil }

                return FileItem(
                    name: url.lastPathComponent,
                    url: url,
                    isDirectory: resourceValues.isDirectory == true,
                    creationDate: resourceValues.creationDate,
                    modificationDate: resourceValues.contentModificationDate,
                    size: resourceValues.totalFileSize
                )
            }
            self.items = items
        } catch {
            sendEvent(.didFailToFetchFiles)
        }
    }
}
