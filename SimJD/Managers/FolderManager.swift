//
//  FolderManager.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import SwiftUI

@Observable
final class FolderManager {
    private let client: FolderClient

    init(_ client: FolderClient = .live) {
        self.client = client
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
            return .failure(.message(error.localizedDescription))
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
            return .failure(.message(error.localizedDescription))
        }
    }
}
