//
//  DocumentFolderViewCoordinator.swift
//  SimJD
//
//  Created by John Demirci on 4/14/25.
//

import SwiftUI

@MainActor
@Observable
final class DocumentFolderCoordinator {
    enum Action {
        case documentFolderViewEvent(DocumentsFolderViewModel.Event)
    }

    enum Alert {
        case didFailToFetchFiles
        case didFailToFindSelectedFile
        case didFailToOpenFile
    }

    enum Destination: Hashable {
        case folder(URL)
    }

    var alert: Alert?
    var destination: [Destination] = []
	private let folderManager: FolderManager

	init(folderManager: FolderManager = .live) {
		self.folderManager = folderManager
	}

    func handleAction(_ action: Action) {
        switch action {
        case .documentFolderViewEvent(let event):
            switch event {
            case .didFailToFetchFiles:
                self.alert = .didFailToFetchFiles

            case .didFailToFindSelectedFile:
                self.alert = .didFailToFindSelectedFile

            case .didFailToOpenFile:
                self.alert = .didFailToOpenFile

            case .didSelect(let item):
                switch item.isDirectory {
                case true:
                    self.destination.append(.folder(item.url))
                case false:
					if case .failure = folderManager.openFile(item.url) {
						alert = .didFailToOpenFile
					}
                }

            case .didSelectOpenInFinder(let item):
				if case .failure = folderManager.openFile(item.url) {
					alert = .didFailToOpenFile
				}
            }
        }
    }
}
