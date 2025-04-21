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
	enum Event: Equatable {
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
	private let copyBoard: CopyBoardProtocol
	private let folderManager: FolderManager

    init(
        folderURL: URL,
		copyBoard: CopyBoardProtocol = CopyBoard(),
		folderManager: FolderManager = .live,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.folderURL = folderURL
		self.copyBoard = copyBoard
		self.folderManager = folderManager
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


		copyBoard.clear()
		copyBoard.copy(item.url.absoluteString)
    }

	func fetchFileItems() {
		switch folderManager.fetchFileItems(at: folderURL) {
		case .success(let items):
			self.items = items
		case .failure(let error):
			self.sendEvent(.didFailToFetchFiles)
		}
	}
}
