//
//  InstalledApplicationMoreViewModel.swift
//  SimJD
//
//  Created by John Demirci on 5/19/25.
//

import SwiftUI
import XCLogParser

@MainActor
@Observable
final class InstalledxApplicationMoreViewModel {
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

    func generateFields() {
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

    func getPathToAppDerivedData() {
        do {
            let urls = try FileManager
                .default
                .contentsOfDirectory(
                    at: .derivedDataURL,
                    includingPropertiesForKeys: [
                        .isDirectoryKey,
                        .creationDateKey,
                        .contentModificationDateKey,
                        .contentTypeKey,
                        .totalFileSizeKey
                    ]
                )

            let stringValues = urls.map(\.absoluteString)
            let applicationDerivedDataURLString = stringValues.first { (urlString: String) in
                urlString.localizedStandardContains(detail.displayName!)
            }

            guard
                let applicationDerivedDataURLString
            else { return }

            self.fields.append(
                InstalledApplicationMoreView.Field(
                    key: "DerivedData Path",
                    value: applicationDerivedDataURLString
                )
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func didSelectLaunch() {
        guard let ddField = fields.first(where: { (field: InstalledApplicationMoreView.Field) in
            field.key == "DerivedData Path"
        }) else { return }

        let url = URL(filePath: ddField.value)
            .appendingPathComponent("Build")
            .appendingPathComponent("Products")
            .appendingPathComponent("Debug-iphonesimulator")
            .appendingPathComponent("\(detail.displayName!).app", conformingTo: .application)

        guard let selectedSimulator = simulatorManager.selectedSimulator else {
            // TODO: handle error
            return
        }

        let _ = Shell.shared.execute(.installApp(selectedSimulator.id, url.path()))
        let _ = Shell.shared.execute(.launchApp(selectedSimulator.id, detail.bundleIdentifier!))
    }

    func didSelectOpenInXcode() {
        guard let ddField = fields.first(where: { (field: InstalledApplicationMoreView.Field) in
            field.key == "DerivedData Path"
        }) else { return }

        let url = URL(filePath: ddField.value)
            .appendingPathComponent("info.plist", conformingTo: .propertyList)

        do {
            let data = try Data(contentsOf: url)
            if let plist = try PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
            ) as? [String: Any] {
                guard let path = plist["WorkspacePath"] as? String else {
                    return
                }

                let _ = Shell.shared.execute(.openPath(path))
            } else {
                print("Failed to cast plist to [String: Any]")
            }
        } catch {
            print("Error reading plist: \(error)")
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

extension URL {
    static var derivedDataURL: URL {
        guard let url = UserDefaults.standard.url(forKey: Setting.derivedDataPath.key) else {
            return .defaultDerivedDataURL
        }
        return url
    }
}
