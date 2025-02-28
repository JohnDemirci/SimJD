//
//  FilesystemCoordinatorViewModel.swift
//  SimJD
//
//  Created by John Demirci on 2/28/25.
//

import SwiftUI

@MainActor
@Observable
final class FileSystemCoordinatingViewModel {
    enum Action {
        case fileSystemViewEvent(FileSystemView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case fileFetchingError
        case fileFindingError
        case fileOpeningError

        var id: AnyHashable { self }
    }

    var alert: Alert?

    func handleAction(_ action: Action) {
        switch action {
        case .fileSystemViewEvent(let event):
            switch event {
            case .didFailToFetchFiles:
                alert = .fileFetchingError
            case .didFailToFindSelectedFile:
                alert = .fileFindingError
            case .didFailToOpenFile:
                alert = .fileOpeningError
            }
        }
    }
}
