//
//  InstalledApplicationDetailView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct InstalledApplicationAction: Identifiable {
    let name: String
    let action: () -> Void

    var id: String { name }
}

struct InstalledApplicationDetailView: View {
    enum Event {
        case couldNotOpenSandboxFolder
        case couldNotOpenUserDefaults
        case didSelectRemoveUserDefaults
        case didSelectUninstallApplication(Simulator)
    }

    @Environment(FolderManager.self) private var folderManager
    @Environment(SimulatorManager.self) private var simulatorManager
    @EnvironmentObject private var navigator: FileSystemNavigator

    @State private var selection: InstalledApplicationAction.ID?

    private let installedApplication: InstalledAppDetail
    private let sendEvent: (Event) -> Void

    init(
        installedApplication: InstalledAppDetail,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.installedApplication = installedApplication
        self.sendEvent = sendEvent
    }

    var body: some View {
        Table(actions, selection: $selection) {
            TableColumn("Action") { item in
                Text(item.name)
            }
        }
        .contextMenu(
            forSelectionType: InstalledApplicationAction.ID.self,
            menu: { _ in EmptyView() },
            primaryAction: { selections in
                guard let selection = selections.first else { return }
                guard let choice = actions.first(where: { $0.id == selection }) else { return }
                choice.action()
            }
        )
        .scrollContentBackground(.hidden)
    }
}

extension InstalledApplicationDetailView {
    private var actions: [InstalledApplicationAction] {
        [
            .init(name: "Application Sandbox Data", action: {
                guard let path = installedApplication.dataContainer else { return }
                let expandedPath = NSString(string: path).expandingTildeInPath
                let fileURL = URL(fileURLWithPath: expandedPath)
                navigator.add(.fileSystem(url: fileURL))
            }),
            .init(name: "Open User Defaults", action: {
                switch folderManager.openUserDefaultsFolder(installedApplication) {
                case .success:
                    break

                case .failure:
                    sendEvent(.couldNotOpenUserDefaults)
                }
            }),
            .init(name: "Remove UserDefaults", action: {
                sendEvent(.didSelectRemoveUserDefaults)
            }),
            .init(name: "Uninstall Application", action: {
                guard let selectedSimulator = simulatorManager.selectedSimulator else { return }
                sendEvent(.didSelectUninstallApplication(selectedSimulator))
            })
        ]
    }
}
