//
//  SimulatorDetailsViewCoordinator.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SimulatorDetailsViewCoordinator: CoordinatingView {
    enum Action {
        case simulatorDetailsViewEvent(SimulatorDetailsView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case didDeleteSimulator
        case didFailToDeleteSimulator
        case didFailToEraseContents
        case didSelectDeleteSimulator(Simulator)
        case didSelectEraseData(Simulator)

        var id: AnyHashable { self }
    }

    @Environment(FolderManager.self) private var folderManager
    @Environment(SimulatorManager.self) private var simManager

    @State var alert: Alert?

    var body: some View {
        SimulatorDetailsView { event in
            handleAction(.simulatorDetailsViewEvent(event))
        }
        .nsAlert(item: $alert) {
            switch $0 {
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

private extension SimulatorDetailsViewCoordinator {
    func didSelectDeleteSimulatorAlert(
        _ simulator: Simulator
    ) -> JDAlert {
        JDAlert(
            title: "Are you sure you want to delete this simulator?",
            message: "This will delete the simulator entirely",
            button1: AlertButton(title: "Delete") {
                switch simManager.deleteSimulator(simulator) {
                case .success:
                    Task {
                        try? await Task.sleep(for: .seconds(1))

                        await MainActor.run {
                            self.alert = .didDeleteSimulator
                        }
                    }
                case .failure:
                    Task {
                        try? await Task.sleep(for: .seconds(1))

                        await MainActor.run {
                            self.alert = .didFailToDeleteSimulator
                        }
                    }
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
                action: {
                    switch simManager.eraseContents(in: simulator) {
                    case .success:
                        break
                    case .failure:
                        Task {
                            try? await Task.sleep(for: .seconds(1))

                            await MainActor.run {
                                self.alert = .didFailToEraseContents
                            }
                        }
                    }
                }
            ),
            button2: AlertButton(
                title: "Dismiss",
                action: { }
            )
        )
    }
}
