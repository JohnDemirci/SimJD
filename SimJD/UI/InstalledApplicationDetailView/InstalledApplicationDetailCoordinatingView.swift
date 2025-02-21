//
//  InstalledApplicationDetailCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct InstalledApplicationDetailCoordinatingView: CoordinatingView {
    enum Action {
        case installedApplicationDetailViewEvent(InstalledApplicationDetailView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case couldNotOpenUserDefaults
        case couldNotRemoveApplication
        case couldNotRemoveUserDefaults
        case didSelectRemoveUserDefaults
        case didSelectUnisntallApplication(Simulator)
        case didUnisntallApplication(InstalledAppDetail)
        case didRemoveUserDefaults

        var id: AnyHashable { self }
    }

    @Environment(FolderManager.self) private var folderManager
    @Environment(SimulatorManager.self) private var simulatorManager
    @EnvironmentObject private var navigator: FileSystemNavigator

    @State var alert: Alert?

    private let installedApplication: InstalledAppDetail

    init(installedApplication: InstalledAppDetail) {
        self.installedApplication = installedApplication
    }

    var body: some View {
        InstalledApplicationDetailView(
            installedApplication: installedApplication,
            sendEvent: {
                handleAction(.installedApplicationDetailViewEvent($0))
            }
        )
        .nsAlert(item: $alert) {
            return switch $0 {
            case .couldNotOpenUserDefaults:
                JDAlert(title: "Unable to open User Defaults Folder")
            case .couldNotRemoveApplication:
                JDAlert(title: "Could not Remove Application")
            case .couldNotRemoveUserDefaults:
                JDAlert(title: "Could not Remove User Defaults")
            case .didSelectRemoveUserDefaults:
                JDAlert(
                    title: "Remove User Defaults",
                    message: "Are you sure about removing the user defaults folder for this application?",
                    button1: AlertButton(
                        title: "Remove",
                        action: {
                            switch folderManager.removeUserDefaults(installedApplication) {
                            case .success:
                                Task {
                                    try? await Task.sleep(for: .seconds(1))

                                    await MainActor.run {
                                        self.alert = .didRemoveUserDefaults
                                    }
                                }
                            case .failure:
                                Task {
                                    try? await Task.sleep(for: .seconds(1))

                                    await MainActor.run {
                                        self.alert = .couldNotRemoveUserDefaults
                                    }
                                }
                            }
                        }
                    ),
                    button2: AlertButton(
                        title: "Cancel",
                        action: { }
                    )
                )
            case .didSelectUnisntallApplication(let simulator):
                JDAlert(
                    title: "Remove Application from Simulator",
                    message: "Are you sure about removing the application?",
                    button1: AlertButton(title: "Remove") {
                        switch simulatorManager.uninstall(
                            installedApplication,
                            simulatorID: simulator.id
                        ) {
                        case .success:
                            Task {
                                try? await Task.sleep(for: .seconds(1))

                                await MainActor.run {
                                    self.alert = .didUnisntallApplication(installedApplication)
                                }
                            }

                        case .failure:
                            Task {
                                try? await Task.sleep(for: .seconds(1))

                                await MainActor.run {
                                    self.alert = .couldNotRemoveApplication
                                }
                            }
                        }
                    },
                    button2: AlertButton(title: "Cancel", action: { })
                )
            case .didUnisntallApplication:
                JDAlert(title: "Successfully Uninstalled Application")
            case .didRemoveUserDefaults:
                JDAlert(title: "User Defaults Removed")
            }
        }
    }
}

extension InstalledApplicationDetailCoordinatingView {
    func handleAction(_ action: Action) {
        switch action {
        case .installedApplicationDetailViewEvent(let event):
            switch event {
            case .couldNotOpenUserDefaults:
                self.alert = .couldNotOpenUserDefaults

            case .didSelectRemoveUserDefaults:
                self.alert = .didSelectRemoveUserDefaults

            case .didSelectUninstallApplication(let simulator):
                self.alert = .didSelectUnisntallApplication(simulator)
            }
        }
    }
}
