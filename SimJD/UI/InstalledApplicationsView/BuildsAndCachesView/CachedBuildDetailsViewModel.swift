//
//  CachedBuildDetailsViewModel.swift
//  SimJD
//
//  Created by John Demirci on 6/7/25.
//

import SwiftUI

@Observable
@MainActor
final class CachedBuildDetailsViewModel {
    enum Event {
        case didSelectLaunchInSimulator(URL, String)
    }

    var items: [String: String]?
    var pathToAppBinary: URL?
    var pathToDetails: URL?

    private let details: InstalledAppDetail
    private let fileItem: FileItem
    private let sendEvent: (Event) -> Void

    init(
        details: InstalledAppDetail,
        fileItem: FileItem,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.details = details
        self.fileItem = fileItem
        self.sendEvent = sendEvent
    }

    func handleViewEvent(_ event: CachedBuildDetailsView.Event) {
        switch event {
        case .didLoadView:
            handleViewDidLoad()

        case .didSelectLaunchInSimulator:
            handleDidSelectLaunchInSimulator()
        }
    }
}

private extension CachedBuildDetailsViewModel {
    func handleViewDidLoad() {
        let urls = try! FileManager
            .default
            .contentsOfDirectory(
                at: fileItem.url,
                includingPropertiesForKeys: [
                    .isDirectoryKey,
                    .creationDateKey,
                    .contentModificationDateKey,
                    .contentAccessDateKey,
                    .contentTypeKey,
                    .totalFileSizeKey
                ]
            )

        self.pathToAppBinary = urls.first { (url: URL) in
            return url.path().localizedStandardContains("\(details.displayName!).app")
        }

        self.pathToDetails = urls.first { (url: URL) in
            url.path().localizedStandardContains("details.json")
        }

        if let pathToDetails {
            readJsonFile()
        }
    }

    func readJsonFile() {
        guard let pathToDetails else { return }

        do {
            let data = try Data(contentsOf: pathToDetails)
            let decoded = try JSONDecoder().decode([String: String].self, from: data)
            self.items = decoded
        } catch {
            fatalError("Failed to read or decode JSON file: \(error)")
        }
    }

    func handleDidSelectLaunchInSimulator() {
        guard let pathToAppBinary else { return }
        sendEvent(.didSelectLaunchInSimulator(pathToAppBinary, details.bundleIdentifier!))
    }
}
