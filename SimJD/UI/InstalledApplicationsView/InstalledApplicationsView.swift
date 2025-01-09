//
//  InstalledApplicationsView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct InstalledApplicationsView: View {
    enum Event {
        case didFailToFetchInstalledApps(Failure)
        case didFailToRetrieveApplication
        case didSelectApp(InstalledAppDetail)
    }

    @Environment(SimulatorManager.self) private var simulatorManager
    @Environment(FolderManager.self) private var folderManager

    @State private var selectedApp: InstalledAppDetail.ID?

    private let sendEvent: (Event) -> Void

    init(sendEvent: @escaping (Event) -> Void) {
        self.sendEvent = sendEvent
    }

    var body: some View {
        OptionalView(simulatorManager.selectedSimulator) { selectedSimulator in
            Table(
                simulatorManager.installedApplications[selectedSimulator.id] ?? [],
                selection: $selectedApp
            ) {
                TableColumn("Name") { item in
                    HStack {
                        Text(item.displayName ?? "")
                    }
                }

                TableColumn("Bundle ID") { item in
                    Text(item.bundleIdentifier ?? "")
                }

                TableColumn("Type") { item in
                    Text(item.applicationType ?? "")
                }

                TableColumn("Path") { item in
                    Text(item.path ?? "")
                }
            }
        }
        .contextMenu(
            forSelectionType: InstalledAppDetail.ID.self,
            menu: { selections in
                Button("Copy Bundle Identifier") {
                    guard
                        let installedApp = getInstalledAppFromSelections(selections),
                        let bundleID = installedApp.bundleIdentifier
                    else { return }

                    copyToClipboard(bundleID)
                }

                Button("Copy Data Container Path") {
                    guard
                        let installedApp = getInstalledAppFromSelections(selections),
                        let dataContainer = installedApp.dataContainer
                    else { return }

                    copyToClipboard(dataContainer)
                }

                Button("Copy Application Path") {
                    guard
                        let installedApp = getInstalledAppFromSelections(selections),
                        let path = installedApp.path
                    else { return }

                    copyToClipboard(path)
                }

                Button("Copy Bundle Path") {
                    guard
                        let installedApp = getInstalledAppFromSelections(selections),
                        let bundle = installedApp.bundle
                    else { return }

                    copyToClipboard(bundle)
                }
            },
            primaryAction: { selectedItems in
                guard let installedAppDetail = getInstalledAppFromSelections(selectedItems) else { return }
                sendEvent(.didSelectApp(installedAppDetail))
            }
        )
        .scrollContentBackground(.hidden)
        .onChange(of: simulatorManager.selectedSimulator, initial: true) {
            guard let selectedSimulator = simulatorManager.selectedSimulator else { return }

            switch simulatorManager.fetchInstalledApplications(for: selectedSimulator) {
            case .success:
                break

            case .failure(let error):
                sendEvent(.didFailToFetchInstalledApps(error))
            }
        }
    }

    func getInstalledAppFromSelections(
        _ selections: Set<InstalledAppDetail.ID>
    ) -> InstalledAppDetail? {
        guard
            let selection = selections.first,
            let selectedSimulator = simulatorManager.selectedSimulator,
            let installedApps = simulatorManager.installedApplications[selectedSimulator.id],
            let selectedApp = installedApps.first(where: { $0.bundleIdentifier == selection })
        else {
            sendEvent(.didFailToRetrieveApplication)
            return nil
        }

        return selectedApp
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text , forType: .string)
    }
}
