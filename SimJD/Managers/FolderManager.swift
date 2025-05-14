//
//  FolderManager.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import SwiftUI

final class FolderManager: Sendable {
    private let client: FolderClient

#if DEBUG
    static let debug = FolderManager(.testing)
#endif
    static let live = FolderManager(.live)


    init(_ client: FolderClient = .live) {
        self.client = client
    }

    func fetchFileItems(at url: URL) -> Result<[FileItem], Failure> {
        client.fetchFileItems(at: url)
    }

    func openFile(_ url: URL) -> Result<Void, Failure> {
        client.openFile(url)
    }

    func openUserDefaultsFolder(_ app: InstalledAppDetail) -> Result<Void, Failure> {
        guard let folderPath = app.dataContainer else {
            return .failure(.message("No User Defaults Folder"))
        }

        guard let bundleIdentifier = app.bundleIdentifier else {
            return .failure(.message("No Bundle Identifier"))
        }

        switch client.openUserDefaults(container: folderPath, bundleID: bundleIdentifier) {
        case .success:
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    func removeUserDefaults(_ app: InstalledAppDetail) -> Result<Void, Failure> {
        guard let folderPath = app.dataContainer else {
            return .failure(.message("No User Defaults Folder"))
        }

        guard let bundleIdentifier = app.bundleIdentifier else {
            return .failure(.message("No Bundle Identifier"))
        }

        switch client.removeUserDefaults(container: folderPath, bundleID: bundleIdentifier) {
        case .success:
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }
}
