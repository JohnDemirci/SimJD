//
//  SidebarView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SidebarView: View {
    @Bindable var simulatorManager: SimulatorManager
    var body: some View {
        List {
            ForEach(simulatorManager.simulators.keys) { key in
                Section(key.name) {
                    ForEach(simulatorManager.simulators[key] ?? []) { simulator in
                        SidebarButtonView(
                            simManager: simulatorManager,
                            simulator: simulator
                        )
                    }
                }
                .inCase(simulatorManager.simulators[key]?.isEmpty ?? true) {
                    EmptyView()
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}
