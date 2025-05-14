//
//  SimulatorDetailsViewCoordinator.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SimulatorDetailsVCoordinatingView: View {
    @State private var coordinator = SimulatorDetailsCoordinator()

    private let simManager: SimulatorManager = .live

    @State var alert: Alert?

    var body: some View {
        SimulatorDetailsView(
            viewModel: SimulatorDetailsViewModel(sendEvent: { (event: SimulatorDetailsViewModel.Event) in
                coordinator.handleAction(.simulatorDetailsViewEvent(event))
            })
        )
        .nsAlert(item: $coordinator.alert) { (alert: SimulatorDetailsCoordinator.Alert) in
            coordinator.getJDAlert(for: alert)
        }
        .sheet(item: $coordinator.sheetDestination) { (destination: SimulatorDetailsCoordinator.SheetDestination) in
            switch destination {
            case .batterySettings(let simulator, let state, let level):
                BatterySettingsView(
                    viewModel: BatterySettingsViewModel(
                        simulator: simulator,
                        manager: simManager,
                        state: state,
                        level: level,
                        sendEvent: { (event: BatterySettingsViewModel.Event) in
                            coordinator.handleAction(.simulatorBatterySettingsViewModelEvent(event))
                        }
                    )
                )
            }
        }
    }
}
