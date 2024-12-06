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
    private let simulatorClient: SimulatorClient

    init(
        client: FolderClient,
        simulatorClient: SimulatorClient
    ) {
        self.client = client
        self.simulatorClient = simulatorClient
    }

    func openDocumentsFolder(_ simulator: Simulator) -> Result<Void, Failure> {
        switch client.openSimulatorDocuments(simulator.id) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(.message(error.localizedDescription))
        }
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

    func openApplicationSupport(_ app: InstalledAppDetail) -> Result<Void, Failure> {
        guard let folderPath = app.dataContainer else {
            return .failure(.message("No Application Support Folder"))
        }

        switch client.openAppSandboxFolder(folderPath) {
        case .success:
            return .success(())

        case .failure(let error):
            return .failure(.message(error.localizedDescription))
        }
    }

    func uninstall(
        _ app: InstalledAppDetail,
        simulatorID: String
    ) -> Result<Void, Failure> {
        if app.applicationType == "System" {
            return .failure(.message("cannot remove system apps"))
        }

        guard let bundleIdentifier = app.bundleIdentifier else {
            return .failure(.message("No Bundle Identifier"))
        }

        switch simulatorClient.uninstallApp(bundleIdentifier, at: simulatorID) {
        case .success:
            return .success(())

        case .failure(let error):
            return .failure(.message("Could not uninstall app: \(error)"))
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
