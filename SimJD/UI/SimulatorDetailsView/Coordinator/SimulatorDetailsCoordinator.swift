//
//  SimulatorDetailsCoordinator.swift
//  SimJD
//
//  Created by John Demirci on 3/29/25.
//

import SwiftUI

@MainActor
@Observable
final class SimulatorDetailsCoordinator {
    enum Action {
        case batterySettingsViewModelEvent(BatterySettingsViewModel.Event)
        case simulatorDetailsViewModelEvent(SimulatorDetailsViewModel.Event)
    }

    enum Alert: Hashable, Identifiable {
        case didChangeState
        case didDeleteSimulator
        case didFailToChangeState
        case didFailToDeleteSimulator
        case didFailToEraseContents
        case didFailToRetrieveBatteryState
        case didSelectDeleteSimulator(Simulator)
        case didSelectEraseData(Simulator)
        case simulatorNotBooted

        var id: AnyHashable { self }
    }

    enum SheetDestination: Hashable, Identifiable {
        case batterySettings(Simulator, BatteryState, Int)

        var id: AnyHashable { self }
    }

    private let simManager: SimulatorManager
    var alert: Alert?
    var sheetDestination: SheetDestination?

    init(simManager: SimulatorManager = .live) {
        self.simManager = simManager
    }

    func handleAction(_ action: Action) {
        switch action {
        case .simulatorDetailsViewModelEvent(let event):
            handleSimulatorDetailsViewModelEvent(event)

        case .batterySettingsViewModelEvent(let event):
            handleBatterySettingsViewModelEvent(event)
        }
    }
}

// MARK: - Alert

extension SimulatorDetailsCoordinator {
    func getJDAlert(for alert: Alert) -> JDAlert {
        switch alert {
        case .didChangeState:
            JDAlert(title: "Simulator state changed ✅")
        case .didDeleteSimulator:
            JDAlert(title: "Simulator deleted")
        case .didFailToChangeState:
            JDAlert(title: "Failed to change simulator state")
        case .didFailToDeleteSimulator:
            JDAlert(title: "Simulator deletion failed")
        case .didFailToEraseContents:
            JDAlert(title: "Simulator contents erasure failed")
        case .didFailToRetrieveBatteryState:
            JDAlert(title: "Failed to retrieve battery state")
        case .didSelectDeleteSimulator(let simulator):
            self.didSelectDeleteSimulatorAlert(simulator)
        case .didSelectEraseData(let simulator):
            self.didSelectEraseDataAlert(simulator: simulator)
        case .simulatorNotBooted:
            JDAlert(title: "Simulator not booted")
        }
    }

    func didSelectDeleteSimulatorAlert(
        _ simulator: Simulator
    ) -> JDAlert {
        JDAlert(
            title: "Are you sure you want to delete this simulator?",
            message: "This will delete the simulator entirely",
            button1: AlertButton(title: "Delete") { [weak self] in
                switch self?.simManager.deleteSimulator(simulator) {
                case .success:
                    self?.handleDidDeleteSimulator()
                case .failure:
                    self?.handleDidFailToDeleteSimulator()
                case .none:
                    break
                }
            },
            button2: AlertButton(title: "Cancel") { }
        )
    }

    func didSelectEraseDataAlert(simulator: Simulator) -> JDAlert {
        JDAlert(
            title: "Erase All Simulator Data?",
            message: "This will behave similarly to a factory reset. Are you sure you want to erase all simulator data?",
            button1: AlertButton(
                title: "Erase Content & Settings",
                action: { [weak self] in
                    self?.handleDidSelectEraseSimulatorContent(simulator)
                }
            ),
            button2: AlertButton(
                title: "Dismiss",
                action: { }
            )
        )
    }
}

private extension SimulatorDetailsCoordinator {
    func handleDidDeleteSimulator() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            self.alert = .didDeleteSimulator
        }
    }

    func handleDidFailToDeleteSimulator() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            self.alert = .didFailToDeleteSimulator
        }
    }

    func handleDidSelectEraseSimulatorContent(_ simulator: Simulator) {
        switch simManager.eraseContents(in: simulator) {
        case .success:
            break
        case .failure:
            Task {
                try? await Task.sleep(for: .seconds(1))
                self.alert = .didFailToEraseContents
            }
        }
    }
}

// MARK: - Battery Settings View Model Event

private extension SimulatorDetailsCoordinator {
    func handleBatterySettingsViewModelEvent(_ event: BatterySettingsViewModel.Event) {
        switch event {
        case .didChangeBatteryState:
            self.alert = .didChangeState

        case .didFailToChangeState:
            self.alert = .didFailToChangeState
        }
    }
}

// MARK: - Simulator Details View Event

private extension SimulatorDetailsCoordinator {
    func handleSimulatorDetailsViewModelEvent(_ event: SimulatorDetailsViewModel.Event) {
        switch event {
        case .didSelectDeleteSimulator(let simulator):
            self.alert = .didSelectDeleteSimulator(simulator)

        case .didSelectEraseContentAndSettings(let simulator):
            self.alert = .didSelectEraseData(simulator)

        case .didSelectBatterySettings(let simulator, let state, let level):
            guard simulator.state == "Booted" else {
                self.alert = .simulatorNotBooted
                return
            }

            self.sheetDestination = .batterySettings(simulator, state, level)

        case .didFailToRetrieveBatteryState:
            self.alert = .didFailToRetrieveBatteryState
        }
    }
}
