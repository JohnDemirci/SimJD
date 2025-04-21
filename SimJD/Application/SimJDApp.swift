//
//  SimJDApp.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import SwiftUI

@main
struct SimJDApp: App {
    var body: some Scene {
        WindowGroup {
            InitialView()
        }

        Settings {
            SettingsView()
        }
    }
}
