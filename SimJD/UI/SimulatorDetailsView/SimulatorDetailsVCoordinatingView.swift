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
        .alert(item: $alert) {
            switch $0 {
            case .didDeleteSimulator:
                SwiftUI.Alert(title: Text("Simulator deleted"))
            case .didFailToDeleteSimulator:
                SwiftUI.Alert(title: Text("Simulator deletion failed"))
            case .didFailToEraseContents:
                SwiftUI.Alert(title: Text("Simulator contents erasure failed"))
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
    ) -> SwiftUI.Alert {
        SwiftUI.Alert(
            title: Text("Are you sure you want to delete this simulator?"),
            message: Text("This will delete the simulator entirely"),
            primaryButton: .default(Text("Delete")) {
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
            secondaryButton: .cancel()
        )
    }

    func didSelectEraseDataAlert(simulator: Simulator) -> SwiftUI.Alert {
        SwiftUI.Alert(
            title: Text("Erase All Simulator Data?"),
            message: Text("This will behave similarly to a factory reset. Are you sure you want to erase all simulator data?"),
            primaryButton: .default(
                Text("Erase Data"),
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
            secondaryButton: .cancel()
        )
    }
}
