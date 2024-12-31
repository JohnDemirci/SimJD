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
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn

    init() {
        let simulatorClient: SimulatorClient = .live
        let folderClient: FolderClient = .live

        self.simulatorManager = SimulatorManager(simulatorClient: simulatorClient)

        self.folderManager = FolderManager(
            client: folderClient,
            simulatorClient: simulatorClient
        )
    }

    var body: some Scene {
        WindowGroup {
            NavigationSplitView(
                columnVisibility: $visibility,
                sidebar: {
                    SidebarView(simulatorManager: simulatorManager)
                        .navigationSplitViewColumnWidth(300)
                },
                detail: {
                    SimulatorDetailsViewCoordinator(
                        folderManager: folderManager,
                        simulatorManager: simulatorManager
                    )
                }
            )
            .toolbarBackground(.hidden, for: .windowToolbar)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Image(.logo)
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
}
