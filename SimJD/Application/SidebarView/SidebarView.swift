//
//  SidebarView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SidebarView: View {
    private let simulatorManager: SimulatorManager = .live
	@Environment(\.colorScheme) private var colorScheme

    var body: some View {
        @Bindable var simManager = simulatorManager
        List {
            Button(
                action: {
                    simulatorManager.fetchRuntimes()
                    simulatorManager.fetchAvailableDeviceTypes()
                },
                label: {
                    Image(systemName: "plus")
                }
            )
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
        .background(colorScheme == .dark ? Color.black : Color.white)
        .sheet(isPresented: Binding($simManager.availableDeviceTypes)) {
            CreateSimulatorView(
                deviceTypes: simManager.availableDeviceTypes!,
                runtimes: simManager.availableRuntimes!
            )
        }
    }
}
