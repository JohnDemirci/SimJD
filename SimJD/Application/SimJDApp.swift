//
//  SimJDApp.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import SwiftUI

@main
struct SimJDApp: App {
    @State private var simulatorManager: SimulatorManager = .init()
    @State private var folderManager: FolderManager = .init()

    var body: some Scene {
        WindowGroup {
            InitialView()
        }
        .environment(simulatorManager)
        .environment(folderManager)

        Settings {
            SettingsView()
        }
    }
}
