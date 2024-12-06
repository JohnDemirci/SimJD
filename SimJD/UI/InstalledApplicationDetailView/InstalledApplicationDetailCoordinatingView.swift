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
        case couldNotOpenSandboxFolder
        case couldNotOpenUserDefaults
        case couldNotRemoveApplication
        case couldNotRemoveUserDefaults
        case didSelectRemoveUserDefaults
        case didSelectUnisntallApplication(Simulator)

        case didUnisntallApplication(InstalledAppDetail)
        case didRemoveUserDefaults

        var id: AnyHashable {
            "\(self)" as AnyHashable
        }
    }

    @Bindable private var folderManager: FolderManager
    @Bindable private var simulatorManager: SimulatorManager
    @Binding private var installedApps: [InstalledAppDetail]

    @Environment(\.dismiss) private var dismiss

    @State var alert: Alert?

    private let installedApplication: InstalledAppDetail

    init(
        folderManager: FolderManager,
        installedApplication: InstalledAppDetail,
        installedApplications: Binding<[InstalledAppDetail]>,
        simulatorManager: SimulatorManager
    ) {
        self.folderManager = folderManager
        self.installedApplication = installedApplication
        self.simulatorManager = simulatorManager
        self._installedApps = installedApplications
    }

    var body: some View {
        InstalledApplicationDetailView(
            folderManager: folderManager,
            installedApplication: installedApplication,
            simulatorManager: simulatorManager,
            sendEvent: {
                handleAction(.installedApplicationDetailViewEvent($0))
            }
        )
        .alert(item: $alert) {
            switch $0 {
            case .couldNotOpenSandboxFolder:
                SwiftUI.Alert(title: Text("Unable to open Applicatiopn Support Folder"))

            case .couldNotOpenUserDefaults:
                SwiftUI.Alert(title: Text("Unable to open User Defaults Folder"))

            case .didSelectRemoveUserDefaults:
                SwiftUI.Alert(
                    title: Text("Remove User Defaults"),
                    message: Text("Are you sure about removing the user defaults folder for this application?"),
                    primaryButton: .default(Text("Remove")) {
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
                    },
                    secondaryButton: .cancel {
                        self.alert = nil
                    }
                )

            case .didSelectUnisntallApplication(let simulator):
                SwiftUI.Alert(
                    title: Text("Remove Application from Simulator"),
                    message: Text("Are you sure about removing the application?"),
                    primaryButton: .default(Text("Remove")) {
                        switch folderManager.uninstall(
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
                    secondaryButton: .cancel()
                )

            case .couldNotRemoveApplication:
                SwiftUI.Alert(title: Text("Could not Remove Application"))

            case .couldNotRemoveUserDefaults:
                SwiftUI.Alert(title: Text("Could not Remove User Defaults"))

            case .didRemoveUserDefaults:
                SwiftUI.Alert(title: Text("Success ✅"))

            case .didUnisntallApplication(let installedApplication):
                SwiftUI.Alert(
                    title: Text("Success ✅"),
                    message: Text("Successfully Removed Application"),
                    dismissButton: .default(Text("OK")) {
                        withAnimation {
                            installedApps.removeAll {
                                $0 == installedApplication
                            }

                            dismiss()
                        }
                    }
                )
            }
        }
        .onChange(of: simulatorManager.selectedSimulator, initial: false) {
            dismiss()
        }
    }
}

extension InstalledApplicationDetailCoordinatingView {
    func handleAction(_ action: Action) {
        switch action {
        case .installedApplicationDetailViewEvent(let event):
            switch event {
            case .couldNotOpenSandboxFolder:
                self.alert = .couldNotOpenSandboxFolder

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
