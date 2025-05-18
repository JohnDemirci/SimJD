//
//  SimulatorDetailsViewCoordinator.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SimulatorDetailsVCoordinatingView: View {
    @State private var coordinator = SimulatorDetailsCoordinator()
    @State var alert: Alert?

    private let simManager: SimulatorManager = .live

    var body: some View {
        SimulatorDetailsView(
            viewModel: SimulatorDetailsViewModel(sendEvent: { (event: SimulatorDetailsViewModel.Event) in
                coordinator.handleAction(.simulatorDetailsViewModelEvent(event))
            })
        )
        .nsAlert(item: $coordinator.alert) { (alert: SimulatorDetailsCoordinator.Alert) in
            coordinator.getJDAlert(for: alert)
        }
        .sheet(item: $coordinator.sheetDestination) { (destination: SimulatorDetailsCoordinator.SheetDestination) in
            switch destination {
            case .addMedia(let simulator):
                AddMediaView(
                    viewModel: AddMediaViewModel(
                        manager: simManager,
                        simulator: simulator
                    )
                )

            case .batterySettings(let simulator, let state, let level):
                BatterySettingsView(
                    viewModel: BatterySettingsViewModel(
                        level: level,
                        manager: simManager,
                        simulator: simulator,
                        state: state,
                        sendEvent: { (event: BatterySettingsViewModel.Event) in
                            coordinator.handleAction(.batterySettingsViewModelEvent(event))
                        }
                    )
                )
            }
        }
    }
}
