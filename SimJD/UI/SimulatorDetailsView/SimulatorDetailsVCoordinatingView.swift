//
//  SimulatorDetailsViewCoordinator.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SimulatorDetailsViewCoordinator: CoordinatingView {
    enum Action {
        case simulatorDetailViewEvent(SimulatorDetailsView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case didDeleteSimulator
        case didFailToDeleteSimulator
        case didFailToEraseContents
        case didFailToOpenDocumentsFolder
        case didSelectDeleteSimulator(Simulator)
        case didSelectEraseData(Simulator)

        var id: AnyHashable {
            "\(self)" as AnyHashable
        }
    }

    enum Destination: Hashable {
        case geolocation(Simulator)
        case installedApplications
    }

    enum Sheet: Hashable, Identifiable {
        case runningProcesses

        var id: AnyHashable {
            "\(self)" as AnyHashable
        }
    }

    @Bindable private var folderManager: FolderManager
    @Bindable private var simManager: SimulatorManager

    @State var alert: Alert?
    @State var destination: Destination?
    @State var present: Sheet?

    init(
        folderManager: FolderManager,
        simulatorManager: SimulatorManager
    ) {
        self.folderManager = folderManager
        self.simManager = simulatorManager
    }

    var body: some View {
        SimulatorDetailsView(
            folderManager: folderManager,
            simManager: simManager,
            sendEvent: { event in
                handleAction(.simulatorDetailViewEvent(event))
            }
        )
        .alert(item: $alert) {
            switch $0 {
            case .didDeleteSimulator:
                SwiftUI.Alert(title: Text("Success ✅"))

            case .didFailToDeleteSimulator:
                SwiftUI.Alert(title: Text("Failed to Delete Simulator"))

            case .didFailToEraseContents:
                SwiftUI.Alert(title: Text("Could not erase contents"))

            case .didFailToOpenDocumentsFolder:
                SwiftUI.Alert(title: Text("Failed to Open Documents Folder"))

            case .didSelectDeleteSimulator(let simulator):
                didSelectDeleteSimulatorAlert(simulator)

            case .didSelectEraseData(let simulator):
                didSelectEraseDataAlert(simulator: simulator)
            }
        }
        .navigationDestination(item: $destination) {
            switch $0 {
            case .geolocation:
                SimulatorGeolocationCoordinatingView(simManager: simManager)

            case .installedApplications:
                InstalledApplicationsCoordinatingView(
                    folderManager: folderManager,
                    simulatorManager: simManager
                )
            }
        }
        .sheet(item: $present) {
            switch $0 {
            case .runningProcesses:
                NavigationStack {
                    RunningProcessesCoordinatingView(simManager: simManager)
                        .frame(width: 800, height: 600)
                        .navigationTitle("Press ESC to close")
                }
            }
        }
    }
}

extension SimulatorDetailsViewCoordinator {
    func handleAction(_ action: Action) {
        switch action {
        case .simulatorDetailViewEvent(let event):
            switch event {
            case .didFailToEraseContents:
                // TODO: [for later] log
                self.alert = .didFailToEraseContents

            case .didFailToOpenFolder:
                // TODO: [for later] log
                self.alert = .didFailToOpenDocumentsFolder

            case .didSelectDeleteSimulator(let simulator):
                self.alert = .didSelectDeleteSimulator(simulator)

            case .didSelectEraseData(let simulator):
                // TODO: [for later] log
                self.alert = .didSelectEraseData(simulator)

            case .didSelectGeolocation(let simulator):
                navigate(to: .geolocation(simulator))

            case .didSelectInstalledApplications:
                // TODO: [for later] log
                navigate(to: .installedApplications)

            case .didSelectRunningProcesses:
                // TODO: [for later] log
                openSheet(.runningProcesses)
            }
        }
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .installedApplications:
            self.destination = .installedApplications
            
        case .geolocation(let simulator):
            self.destination = .geolocation(simulator)
        }
    }

    func openSheet(_ sheet: Sheet) {
        switch sheet {
        case .runningProcesses:
            self.present = .runningProcesses
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
