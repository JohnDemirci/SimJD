//
//  InstalledApplicationMoreViewModel.swift
//  SimJD
//
//  Created by John Demirci on 5/19/25.
//

import SwiftUI

@MainActor
@Observable
final class InstalledApplicationMoreViewModel {
    let detail: InstalledAppDetail
    let fileManager: FileManager
    private let simulatorManager: SimulatorManager

    var appDerivedDataPath: String = ""
    var fields: [InstalledApplicationMoreView.Field] = []

    init(
        detail: InstalledAppDetail,
        fileManager: FileManager = .default,
        simulatorManager: SimulatorManager = .live
    ) {
        self.detail = detail
        self.fileManager = fileManager
        self.simulatorManager = simulatorManager
    }
}

extension InstalledApplicationMoreViewModel {
    func handleViewEvent(_ event: InstalledApplicationMoreView.Event) {
        switch event {
        case .didSelectCreateCache:
            handleDidSelectCreateCache()

        case .didSelectLaunch:
            handleDidSelectLaunchInSimulator()

        case .didSelectOpenInXcode:
            handleDidSelectOpenInXcode()

        case .viewDidAppear:
            handleViewDidLoad()
        }
    }
}

private extension InstalledApplicationMoreViewModel {
    func handleDidSelectCreateCache() {
        // get derived data folder of the application
        guard let ddField = fields.first(where: { (field: InstalledApplicationMoreView.Field) in
            field.key == "DerivedData Path"
        }) else { return }

        // get the path to the info plist
        let infoPlistResult = URL.getFilePath(for: .infoPlist(ddField.value))

        guard case .success(let infoPlistURL) = infoPlistResult else { return }

        // Get the workspace path
        let workspacePathResult = URL.getFilePath(for: .workspacePath(infoPlistURL))

        guard case .success(let workspacePathURL) = workspacePathResult else { return }
        // remove the last bit of the path so we only have the reference to the folder not the workspace or the project file itself
        let folderURL = workspacePathURL.deletingLastPathComponent()
        // Get the branch name from git
        let gitBranchResult = Shell.shared.execute(.getBranchName(folderURL))
        guard
            case .success(let optionalBranchName) = gitBranchResult,
            let branchName = optionalBranchName?.replacingOccurrences(of: "\n", with: "")
        else { return }
        // Get the commit hash
        let commitHashResult = Shell.shared.execute(.getCommitHash(folderURL))
        guard
            case .success(let optionalCommitHash) = commitHashResult,
            let commitHash = optionalCommitHash?.replacingOccurrences(of: "\n", with: "")
        else { return }
        // Find the application to run on the simulator from the derived data and cache it using the branch name and commit hash as key to identify
        let applicationPathURLResult = URL.getFilePath(
            for: .applicationBinary(
                ddField.value,
                detail.displayName!
            )
        )

        guard case .success(let applicationPathURL) = applicationPathURLResult else { return }
        // Create a folder mamed Simulator Cached Builds
        let cacheDirectory = URL(fileURLWithPath: ddField.value)
            .appendingPathComponent("SimJD-SimulatorBuildCache")
        // Create a folder with the name of commit hash and display name
        let currentBuildCacheDirectory = cacheDirectory
            .appendingPathComponent("\(branchName)_\(commitHash)")

        if fileManager.fileExists(atPath: currentBuildCacheDirectory.path()) {
            try! FileManager.default.removeItem(atPath: currentBuildCacheDirectory.path())
            try! FileManager.default.createDirectory(at: currentBuildCacheDirectory, withIntermediateDirectories: true)
        } else {
            try! FileManager.default.createDirectory(at: currentBuildCacheDirectory, withIntermediateDirectories: true)
        }

        let destinationURL = currentBuildCacheDirectory.appendingPathComponent(applicationPathURL.lastPathComponent)

        try! FileManager.default.copyItem(at: applicationPathURL, to: destinationURL)
    }

    func handleViewDidLoad() {
        func getPathToAppDerivedData() {
            guard
                case .success(let url) = URL.getFilePath(for: .applicationSpecificDerivedData(detail))
            else { return }

            self.fields.append(
                InstalledApplicationMoreView.Field(
                    key: "DerivedData Path",
                    value: url.path()
                )
            )
        }

        Array(detail.dictionaryRepresentation.keys).forEach { (key: String) in
            fields.append(
                InstalledApplicationMoreView.Field(
                    key: key,
                    value: detail[dynamicMember: key] ?? "N/A"
                )
            )
        }

        getPathToAppDerivedData()
    }

    func handleDidSelectOpenInXcode() {
        guard let ddField = fields.first(where: { (field: InstalledApplicationMoreView.Field) in
            field.key == "DerivedData Path"
        }) else { return }

        switch URL.getFilePath(for: .infoPlist(ddField.value)) {
        case .success(let pListURL):
            switch URL.getFilePath(for: .workspacePath(pListURL)) {
            case .success(let workspacePath):
                let _ = Shell.shared.execute(.openPath(workspacePath.path()))
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        case .failure:
            break
        }
    }

    func handleDidSelectLaunchInSimulator() {
        let applicationDerivedDataPath = fields.first { (field: InstalledApplicationMoreView.Field) in
            field.key == "DerivedData Path"
        }

        guard
            let applicationDerivedDataPath,
            case .success(let url) = URL.getFilePath(
                for: .applicationBinary(applicationDerivedDataPath.value, detail.displayName!)
            )
        else { return }

        guard let selectedSimulator = simulatorManager.selectedSimulator else {
            // TODO: handle error
            return
        }

        let _ = Shell.shared.execute(.installApp(selectedSimulator.id, url.path()))
        let _ = Shell.shared.execute(.launchApp(selectedSimulator.id, detail.bundleIdentifier!))
    }
}

extension InstalledApplicationMoreView {
    struct Field: Hashable {
        let key: String
        let value: String
    }
}

extension Collection where Element == InstalledApplicationMoreView.Field {
    func contains(_ key: String) -> Bool {
        first(where: { $0.key == key }) != nil
    }

    func doesNotContain(_ key: String) -> Bool {
        !contains(key)
    }
}

