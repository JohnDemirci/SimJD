//
//  DocumentsFolderViewModel.swift
//  SimJD
//
//  Created by John Demirci on 4/14/25.
//

import SwiftUI

@MainActor
@Observable
final class DocumentsFolderViewModel {
    enum Event {
        case didFailToFetchFiles
        case didFailToFindSelectedFile
        case didFailToOpenFile
        case didSelect(FileItem)
        case didSelectOpenInFinder(FileItem)
    }

    var items: [FileItem] = []
    var selectedItem: FileItem.ID?

    private let sendEvent: (Event) -> Void
    private let folderURL: URL

    init(
        folderURL: URL,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.folderURL = folderURL
        self.sendEvent = sendEvent
    }

    func didDoubleClickOn(_ selectedItems: Set<FileItem.ID>) {
        if selectedItems.count == 1 {
            if selectedItem != selectedItems.first {
                selectedItem = selectedItems.first
            }
        }

        guard let item = self.items.first(where: { fileItem in
            fileItem.id == selectedItem
        }) else {
            sendEvent(.didFailToFindSelectedFile)
            return
        }

        sendEvent(.didSelect(item))
    }

    func didSelectOpenInFinder(_ selectedItems: Set<FileItem.ID>) {
        guard let selectedItem = selectedItems.first else { return }
        guard let item = items.first(where: { fileItem in
            fileItem.id == selectedItem
        }) else { return }

        sendEvent(.didSelectOpenInFinder(item))
    }

    func didSelectCopyPathToClipboard(_ selectedItems: Set<FileItem.ID>) {
        guard let selectedItem = selectedItems.first else { return }
        guard let item = items.first(where: { fileItem in
            fileItem.id == selectedItem
        }) else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.url.absoluteString, forType: .string)
    }

    func fetchFileItems() {
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: folderURL,
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
