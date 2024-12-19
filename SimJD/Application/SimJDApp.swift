//
//  SimJDApp.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import SwiftUI

@main
struct SimJDApp: App {
    @State private var simulatorManager: SimulatorManager
    @State private var folderManager: FolderManager

    init() {
        let simulatorClient: SimulatorClient = .live
        let folderClient: FolderClient = .live

        self.simulatorManager = SimulatorManager(simulatorClient: simulatorClient)

        self.folderManager = FolderManager(
            client: folderClient,
            simulatorClient: simulatorClient
        )
    }

    var simulatorDetailsViewID: AnyHashable {
        "\(simulatorManager.selectedSimulator?.id ?? "") \(simulatorManager.selectedSimulator?.state ?? "")"
    }

    var body: some Scene {
        WindowGroup {
            NavigationSplitView(
                sidebar: {
                    SidebarView(simulatorManager: simulatorManager)
                },
                detail: {
                    NavigationStack {
                        SimulatorDetailsViewCoordinator(
                            folderManager: folderManager,
                            simulatorManager: simulatorManager
                        )
                        .id(simulatorDetailsViewID)
                    }
                }
            )
        }
    }
}
