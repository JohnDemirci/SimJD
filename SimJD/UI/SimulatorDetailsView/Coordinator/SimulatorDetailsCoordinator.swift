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
        case simulatorDetailsViewEvent(SimulatorDetailsViewModel.Event)
    }

    enum Alert: Hashable, Identifiable {
        case didDeleteSimulator
        case didFailToDeleteSimulator
        case didFailToEraseContents
        case didSelectDeleteSimulator(Simulator)
        case didSelectEraseData(Simulator)

        var id: AnyHashable { self }
    }

    private let simManager: SimulatorManager
    var alert: Alert?

    init(simManager: SimulatorManager = .live) {
        self.simManager = simManager
    }

    func handleAction(_ action: Action) {
        switch action {
        case .simulatorDetailsViewEvent(let event):
            switch event {
            case .didSelectDeleteSimulator(let simulator):
                self.alert = .didSelectDeleteSimulator(simulator)
            case .didSelectEraseContentAndSettings(let simulator):
                self.alert = .didSelectEraseData(simulator)
            }
        }
    }
}

extension SimulatorDetailsCoordinator {
    func getJDAlert(for alert: Alert) -> JDAlert {
        switch alert {
        case .didDeleteSimulator:
            JDAlert(title: "Simulator deleted")
        case .didFailToDeleteSimulator:
            JDAlert(title: "Simulator deletion failed")
        case .didFailToEraseContents:
            JDAlert(title: "Simulator contents erasure failed")
        case .didSelectDeleteSimulator(let simulator):
            self.didSelectDeleteSimulatorAlert(simulator)
        case .didSelectEraseData(let simulator):
            self.didSelectEraseDataAlert(simulator: simulator)
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
