//
//  FolderClient.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation
import SwiftUI

struct FolderClient: @unchecked Sendable {
    fileprivate var _fetchFileItems: (URL) -> Result<[FileItem], Failure>
    fileprivate var _openFile: (URL) -> Result<Void, Failure>
    fileprivate var _openUserDefaults: (String, String) -> Result<Void, Failure>
    fileprivate var _removeUserDefaults: (String, String) -> Result<Void, Failure>

    private init(
        _fetchFileItems: @escaping (URL) -> Result<[FileItem], Failure>,
        _openFile: @escaping (URL) -> Result<Void, Failure>,
        _openUserDefaults: @escaping (String, String) -> Result<Void, Failure>,
        _removeUserDefaults: @escaping (String, String) -> Result<Void, Failure>
    ) {
        self._fetchFileItems = _fetchFileItems
        self._openFile = _openFile
        self._openUserDefaults = _openUserDefaults
        self._removeUserDefaults = _removeUserDefaults
    }

    func fetchFileItems(at url: URL) -> Result<[FileItem], Failure> {
        _fetchFileItems(url)
    }

    func openFile(_ url: URL) -> Result<Void, Failure> {
        _openFile(url)
    }

    func openUserDefaults(container: String, bundleID: String) -> Result<Void, Failure> {
        _openUserDefaults(container, bundleID)
    }

    func removeUserDefaults(container: String, bundleID: String) -> Result<Void, Failure> {
        _removeUserDefaults(container, bundleID)
    }
}

extension FolderClient {
    static let live: FolderClient = .init(
        _fetchFileItems: {
            handleFetchFileItems(at: $0)
        },
        _openFile: {
            handleOpenFile($0)
        },
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
        _fetchFileItems: { _ in fatalError("Not implemented") },
        _openFile: { _ in fatalError("Not implemented") },
        _openUserDefaults: { _, _ in fatalError("Not implemented") },
        _removeUserDefaults: { _, _ in fatalError("Not implemented") }
    )

    @discardableResult
    mutating func mutate(
        _fetchFileItems: ((URL) -> Result<[FileItem], Failure>)? = nil,
        _openFile: ((URL) -> Result<Void, Failure>)? = nil,
        _openUserDefaults: ((String, String) -> Result<Void, Failure>)? = nil,
        _removeUserDefaults: ((String, String) -> Result<Void, Failure>)? = nil
    ) -> FolderClient {
        if let _openUserDefaults {
            self._openUserDefaults = _openUserDefaults
        }

        if let _removeUserDefaults {
            self._removeUserDefaults = _removeUserDefaults
        }

        if let _openFile {
            self._openFile = _openFile
        }

        if let _fetchFileItems {
            self._fetchFileItems = _fetchFileItems
        }

        return self
    }
#endif
}

private extension FolderClient {
    static func handleFetchFileItems(at url: URL) -> Result<[FileItem], Failure> {
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
                ]) else { return nil }

                return FileItem(
                    creationDate: resourceValues.creationDate,
                    isDirectory: resourceValues.isDirectory == true,
                    modificationDate: resourceValues.contentModificationDate,
                    name: url.lastPathComponent,
                    size: resourceValues.totalFileSize,
                    url: url
                )
            }

            return .success(items)
        } catch {
            return .failure(Failure.message(error.localizedDescription))
        }
    }

    static func handleOpenFile(_ url: URL) -> Result<Void, Failure> {
        if NSWorkspace.shared.open(url) {
            return .success(())
        }

        return .failure(Failure.message("Could not open file"))
    }

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

private extension FolderClient {
    static func trackIfEnabled(_ command: any TrackableCommand) {
        if UserDefaults.standard.bool(forKey: Setting.enableLogging.key) {
            Task {
                await CommandHistoryTracker.shared.recordExecution(of: command)
            }
        }
    }
}
