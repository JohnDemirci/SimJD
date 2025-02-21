//
//  FolderClient.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation
import SwiftUI

struct FolderClient {
    fileprivate var _openUserDefaults: (String, String) -> Result<Void, Failure>
    fileprivate var _removeUserDefaults: (String, String) -> Result<Void, Failure>

    private init(
        _openUserDefaults: @escaping (String, String) -> Result<Void, Failure>,
        _removeUserDefaults: @escaping (String, String) -> Result<Void, Failure>
    ) {
        self._openUserDefaults = _openUserDefaults
        self._removeUserDefaults = _removeUserDefaults
    }

    func openUserDefaults(container: String, bundleID: String) -> Result<Void, Failure> {
        _openUserDefaults(container, bundleID)
    }

    func removeUserDefaults(container: String, bundleID: String) -> Result<Void, Failure> {
        _removeUserDefaults(container, bundleID)
    }
}

extension FolderClient {
    nonisolated(unsafe)
    static let live: FolderClient = .init(
        _openUserDefaults: {
            handleOpenUserDefaults(container: $0, bundleID: $1)
        },
        _removeUserDefaults: {
            handleRemoveUserDefaults(container: $0, bundleID: $1)
        }
    )

#if DEBUG
    nonisolated(unsafe)
    static var testing: FolderClient = .init(
        _openUserDefaults: { _, _ in fatalError("Not implemented") },
        _removeUserDefaults: { _, _ in fatalError("Not implemented") }
    )

    @discardableResult
    mutating func mutate(
        _openUserDefaults: ((String, String) -> Result<Void, Failure>)? = nil,
        _removeUserDefaults: ((String, String) -> Result<Void, Failure>)? = nil
    ) -> FolderClient {
        if let _openUserDefaults {
            self._openUserDefaults = _openUserDefaults
        }

        if let _removeUserDefaults {
            self._removeUserDefaults = _removeUserDefaults
        }

        return self
    }
#endif
}

private extension FolderClient {
    static func trackIfEnabled(_ command: any TrackableCommand) {
        if UserDefaults.standard.bool(forKey: Setting.enableLogging.key) {
            Task {
                await CommandHistoryTracker.shared.recordExecution(of: command)
            }
        }
    }
}

private extension FolderClient {
    static func handleOpenUserDefaults(container: String, bundleID: String) -> Result<Void, Failure> {
        let string = "\(bundleID).plist"
        let newPath = "\(container)/Library/Preferences/\(string)"
        let fileURL = URL(fileURLWithPath: newPath)

        if !NSWorkspace.shared.open(fileURL) {
            return .failure(Failure.message("Could not open User Defaults Folder"))
        }

        trackIfEnabled(CustomTrackableCommand(fullCommand: "Swift API open file at \(newPath)"))

        return .success(())
    }

    static func handleRemoveUserDefaults(container: String, bundleID: String) -> Result<Void, Failure> {
        let userDefaultsExtension = "\(bundleID).plist"
        let newPath = "\(container)/Library/Preferences/\(userDefaultsExtension)"
        let fileURL = URL(fileURLWithPath: newPath)

        trackIfEnabled(CustomTrackableCommand(fullCommand: "Swift API Remove item at \(newPath)"))

        do {
            try FileManager.default.removeItem(at: fileURL)
            return .success(())
        } catch {
            return .failure(Failure.message("Could not remove User Defaults File"))
        }
    }
}
