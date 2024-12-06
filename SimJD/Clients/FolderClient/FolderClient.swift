//
//  FolderClient.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation
import SwiftUI

struct FolderClient {
    fileprivate var _openAppSandboxFolder: (String) -> Result<Void, Failure>
    fileprivate var _openUserDefaults: (String, String) -> Result<Void, Failure>
    fileprivate var _removeUserDefaults: (String, String) -> Result<Void, Failure>
    fileprivate var _openSimulatorDocuments: (String) -> Result<Void, Failure>

    private init(
        _openAppSandboxFolder: @escaping (String) -> Result<Void, Failure>,
        _openUserDefaults: @escaping (String, String) -> Result<Void, Failure>,
        _removeUserDefaults: @escaping (String, String) -> Result<Void, Failure>,
        _openSimulatorDocuments: @escaping (String) -> Result<Void, Failure>
    ) {
        self._openAppSandboxFolder = _openAppSandboxFolder
        self._openUserDefaults = _openUserDefaults
        self._removeUserDefaults = _removeUserDefaults
        self._openSimulatorDocuments = _openSimulatorDocuments
    }

    func openAppSandboxFolder(_ folder: String) -> Result<Void, Failure> {
        _openAppSandboxFolder(folder)
    }

    func openUserDefaults(container: String, bundleID: String) -> Result<Void, Failure> {
        _openUserDefaults(container, bundleID)
    }

    func removeUserDefaults(container: String, bundleID: String) -> Result<Void, Failure> {
        _removeUserDefaults(container, bundleID)
    }

    func openSimulatorDocuments(_ id: String) -> Result<Void, Failure> {
        _openSimulatorDocuments(id)
    }
}

extension FolderClient {
    nonisolated(unsafe)
    static let live: FolderClient = .init(
        _openAppSandboxFolder: {
            handleOpenSandboxFolder($0)
        },
        _openUserDefaults: {
            handleOpenUserDefaults(container: $0, bundleID: $1)
        },
        _removeUserDefaults: {
            handleRemoveUserDefaults(container: $0, bundleID: $1)
        },
        _openSimulatorDocuments: {
            handleOpenSimulatorDocuments($0)
        }
    )

    #if DEBUG
    nonisolated(unsafe)
    static var testing: FolderClient = .init(
        _openAppSandboxFolder: { _ in fatalError("Not implemented") },
        _openUserDefaults: { _,_ in fatalError("Not implemented") },
        _removeUserDefaults: { _,_ in fatalError("Not implemented") },
        _openSimulatorDocuments: { _ in fatalError("Not implemented") }
    )

    @discardableResult
    mutating func mutate(
        _openAppSandboxFolder:  ((String) -> Result<Void, Failure>)? = nil,
        _openUserDefaults:  ((String, String) -> Result<Void, Failure>)? = nil,
        _removeUserDefaults:  ((String, String) -> Result<Void, Failure>)? = nil,
        _openSimulatorDocuments:  ((String) -> Result<Void, Failure>)? = nil
    ) -> FolderClient {
        if let _openAppSandboxFolder {
            self._openAppSandboxFolder = _openAppSandboxFolder
        }

        if let _openUserDefaults {
            self._openUserDefaults = _openUserDefaults
        }

        if let _removeUserDefaults {
            self._removeUserDefaults = _removeUserDefaults
        }

        if let _openSimulatorDocuments {
            self._openSimulatorDocuments = _openSimulatorDocuments
        }

        return self
    }
    #endif
}

private extension FolderClient {
    static func handleOpenSandboxFolder(_ path: String) -> Result<Void, Failure> {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)
        if !NSWorkspace.shared.open(fileURL) {
            return .failure(Failure.message("Could not open Application Support Folder"))
        }

        return .success(())
    }

    static func handleOpenUserDefaults(container: String, bundleID: String) -> Result<Void, Failure> {
        let string = "\(bundleID).plist"
        let newPath = "\(container)/Library/Preferences/\(string)"
        let fileURL = URL(fileURLWithPath: newPath)

        if !NSWorkspace.shared.open(fileURL) {
            return .failure(Failure.message("Could not open User Defaults Folder"))
        }

        return .success(())
    }

    static func handleRemoveUserDefaults(container: String, bundleID: String) -> Result<Void, Failure> {
        let userDefaultsExtension = "\(bundleID).plist"
        let newPath = "\(container)/Library/Preferences/\(userDefaultsExtension)"
        let fileURL = URL(fileURLWithPath: newPath)

        do {
            try FileManager.default.removeItem(at: fileURL)
            return .success(())
        } catch {
            return .failure(Failure.message("Could not remove User Defaults File"))
        }
    }

    static func handleOpenSimulatorDocuments(_ id: String) -> Result<Void, Failure> {
        let folderPath = "~/Library/Developer/CoreSimulator/Devices/\(id)/data/Documents/"
        let expandedPath = NSString(string: folderPath).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)

        if !NSWorkspace.shared.open(fileURL) {
            return .failure(Failure.message("Could not open \(fileURL)"))
        }

        return .success(())
    }
}
