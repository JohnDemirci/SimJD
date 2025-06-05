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
    enum Action {
        case cachedAppBinaryTableViewEvent(CachedAppBinaryTableView.Event)
    }

    enum Event {
        case didSelectCachedBuildFolder(FileItem, InstalledAppDetail)
    }

    private let simulatorManager: SimulatorManager
    private let sendEvent: (Event) -> Void

    let detail: InstalledAppDetail
    let fileManager: FileManager

    var appDerivedDataPath: String = ""
    var fields: [InstalledApplicationMoreView.Field] = []
    var fileItems: [FileItem]?
    var selectedFileItem: FileItem?

    init(
        detail: InstalledAppDetail,
        sendEvent: @escaping (Event) -> Void,
        fileManager: FileManager = .default,
        simulatorManager: SimulatorManager = .live
    ) {
        self.detail = detail
        self.sendEvent = sendEvent
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

    func handleAction(_ action: Action) {
        switch action {
        case .cachedAppBinaryTableViewEvent(let event):
            switch event {
            case .didSelectCachedFolder(let items):
                didSelectCachedFolder(items)
            }
        }
    }
}

extension InstalledApplicationMoreViewModel {
    func didSelectCachedFolder(_ selectedItems: Set<FileItem.ID>) {
        guard
            let selectedItem = selectedItems.first,
            let fileItem = fileItems?.first(where: { $0.id == selectedItem })
        else { return }

        sendEvent(.didSelectCachedBuildFolder(fileItem, detail))
    }
}

// MARK: - Creating Cache

private extension InstalledApplicationMoreViewModel {
    func handleDidSelectCreateCache() {
        guard
            let ddField = applicationDerivedDataField(),
            let infoPlistURL = infoPlistURL(for: ddField.value),
            let workspacePathURL = workspacePath(infoPlistURL: infoPlistURL),
            let branchName = gitBranchName(at: workspacePathURL.deletingLastPathComponent()),
            let applicationBinaryPath = applicationBinaryPath(
                derivedDataPath: ddField.value,
                displayName: detail.displayName!
            )
        else { return }

        let cacheDirectoryURL = getCacheDirectoryForCurrentBuild(
            derivedDataPath: ddField.value,
            branchName: branchName
        )

        createCacheDirectory(cacheBuildFolderURL: cacheDirectoryURL)
        createAppCacheInCacheDirectory(
            cacheDirectoryURL: cacheDirectoryURL,
            applicationBinaryPathURL: applicationBinaryPath
        )

        getListOfCaches()
    }

    func applicationDerivedDataField() -> InstalledApplicationMoreView.Field? {
        // get derived data folder of the application
        guard let ddField = fields.first(where: { (field: InstalledApplicationMoreView.Field) in
            field.key == "DerivedData Path"
        }) else { return nil }

        return ddField
    }

    func infoPlistURL(for derivedDataPath: String) -> URL? {
        // get the path to the info plist
        let infoPlistResult = URL.getFilePath(for: .infoPlist(derivedDataPath))
        guard case .success(let infoPlistURL) = infoPlistResult else { return nil }
        return infoPlistURL
    }

    func workspacePath(infoPlistURL: URL) -> URL? {
        // Get the workspace path
        let workspacePathResult = URL.getFilePath(for: .workspacePath(infoPlistURL))
        guard case .success(let workspacePathURL) = workspacePathResult else { return nil }
        return workspacePathURL
    }

    func gitBranchName(at workspacePath: URL) -> String? {
        let gitBranchResult = Shell.shared.execute(.getBranchName(workspacePath))
        guard
            case .success(let optionalBranchName) = gitBranchResult,
            let branchName = optionalBranchName?.replacingOccurrences(of: "\n", with: "")
        else { return nil }

        return branchName
    }

    func gitCommitHash(at workspacePath: URL) -> String? {
        let commitHashResult = Shell.shared.execute(.getCommitHash(workspacePath))
        guard
            case .success(let optionalCommitHash) = commitHashResult,
            let commitHash = optionalCommitHash?.replacingOccurrences(of: "\n", with: "")
        else { return nil }

        return commitHash
    }

    func applicationBinaryPath(
        derivedDataPath: String,
        displayName: String
    ) -> URL? {
        let applicationPathURLResult = URL.getFilePath(
            for: .applicationBinary(
                derivedDataPath,
                displayName
            )
        )

        switch applicationPathURLResult {
        case .success(let applicationPathURL):
            return applicationPathURL
        case .failure:
            return nil
        }
    }

    func getCacheDirectoryForCurrentBuild(
        derivedDataPath: String,
        branchName: String
    ) -> URL {
        let cacheDirectory = URL(fileURLWithPath: derivedDataPath)
            .appendingPathComponent("SimJD-SimulatorBuildCache")
        // Create a folder with the name of commit hash and display name
        let currentBuildCacheDirectory = cacheDirectory
            .appendingPathComponent("\(branchName)")

        return currentBuildCacheDirectory
    }

    func createCacheDirectory(cacheBuildFolderURL: URL) {
        if fileManager.fileExists(atPath: cacheBuildFolderURL.path()) {
            try! FileManager.default.removeItem(atPath: cacheBuildFolderURL.path())
            try! FileManager.default.createDirectory(at: cacheBuildFolderURL, withIntermediateDirectories: true)
        } else {
            try! FileManager.default.createDirectory(at: cacheBuildFolderURL, withIntermediateDirectories: true)
        }
    }

    func createAppCacheInCacheDirectory(
        cacheDirectoryURL: URL,
        applicationBinaryPathURL: URL
    ) {
        let destinationURL = cacheDirectoryURL.appendingPathComponent(applicationBinaryPathURL.lastPathComponent)
        try! FileManager.default.copyItem(at: applicationBinaryPathURL, to: destinationURL)
    }
}

private extension InstalledApplicationMoreViewModel {
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

        func getBranchInformation() {
            guard
                let ddField = applicationDerivedDataField(),
                let infoPlistURL = infoPlistURL(for: ddField.value),
                let workspacePathURL = workspacePath(infoPlistURL: infoPlistURL),
                let branchName = gitBranchName(at: workspacePathURL.deletingLastPathComponent())
            else { return }

            fields.append(
                InstalledApplicationMoreView.Field(
                    key: "Current Branch",
                    value: branchName
                )
            )

            guard let commitHash = gitCommitHash(at: workspacePathURL) else { return }

            fields.append(
                InstalledApplicationMoreView.Field(
                    key: "Latest Commit Hash",
                    value: commitHash
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
        getListOfCaches()
        getBranchInformation()
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

    func getListOfCaches() {
        guard let ddField = fields.first(where: { (field: InstalledApplicationMoreView.Field) in
            field.key == "DerivedData Path"
        }) else { return }

        let cacheDirectory = URL(fileURLWithPath: ddField.value)
            .appendingPathComponent("SimJD-SimulatorBuildCache")

        guard fileManager.fileExists(atPath: cacheDirectory.path()) else { return }

        let urls = try! fileManager.contentsOfDirectory(
            at: cacheDirectory, includingPropertiesForKeys: [.nameKey]
        )

        let filteredItems = urls.fileItems.filter { (fileItem: FileItem) in
            !fileItem.name.localizedStandardContains("DS_Store")
        }

        withAnimation {
            self.fileItems = filteredItems
        }
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

