//
//  LogSettingsView.swift
//  SimJD
//
//  Created by John Demirci on 2/19/25.
//

import Foundation
import SwiftUI

enum Setting {
    case enableLogging
    case sidebarVisibility
    case simulatorDirectory

    static var defaultSimulatorDirectory: String { "~/Library/Developer/CoreSimulator/Devices/" }

    var key: String {
        switch self {
        case .enableLogging:
            return "enableLogging"
        case .sidebarVisibility:
            return "sidebarVisibility"
        case .simulatorDirectory:
            return "simulatorDirectory"
        }
    }
}

struct LogSettingsView: View {
    @AppStorage(Setting.enableLogging.key) var enableLogging: Bool = true
    @State private var showHistory: Bool = false

    var body: some View {
        Form {
            Toggle(isOn: $enableLogging) {
                Text("Enable Command Execution Logging")
            }

            Button("Command History") { showHistory = true }
                .listRowBackground(Color.clear)
        }
        .sheet(isPresented: $showHistory) {
            CommandHistoryView(commands: CommandHistoryTracker.shared.commands)
                .frame(maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
        }
    }
}
