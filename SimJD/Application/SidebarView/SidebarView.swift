//
//  SidebarView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import StateJD
import SwiftUI

struct SidebarView: View {
    @Environment(SimulatorManager.self) private var simulatorManager

    var body: some View {
        List {
            ForEach(simulatorManager.simulators.keys) { key in
                Section(key.name) {
                    ForEach(simulatorManager.simulators[key] ?? []) { simulator in
                        SidebarButtonView(simulator: simulator)
                    }
                }
                .inCase(simulatorManager.simulators[key] ?? [] == []) {
                    EmptyView()
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}
