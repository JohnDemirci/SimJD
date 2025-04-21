//
//  InstalledApplicationsCoordinator.swift
//  SimJD
//
//  Created by John Demirci on 4/4/25.
//

import SwiftUI

@MainActor
@Observable
final class InstalledApplicationsCoordinator {
    enum Destination: Hashable {
        case folder(URL)
        case installedApplicationDetails(InstalledAppDetail)
    }

    enum Action {
        case installedApplicationsViewModelEvent(InstalledApplicationsViewModel.Event)
        case installedApplicationDetailViewEvent(InstalledApplicationDetailViewModel.Event)
        case documentFolderViewModelEvent(DocumentsFolderViewModel.Event)
    }

    enum Alert: Hashable, Identifiable {
        case didFailToFetchInstalledApps
        case didFailToRetrieveApp
        case simulatorNotBooted
        case couldNotOpenUserDefaults
        case didFailToFetchFiles
        case didFailToFindSelectedFile
        case didFailToOpenFile
        case couldNotRemoveApplication
        case couldNotRemoveUserDefaults
        case didSelectRemoveUserDefaults(InstalledAppDetail)
        case didSelectUnisntallApplication(Simulator, InstalledAppDetail)
        case didUnisntallApplication(InstalledAppDetail)
        case didRemoveUserDefaults
        case noSelectedSimulator

        var id: AnyHashable { self }
    }

    var alert: Alert?
    var destination: [Destination] = []

    private let folderManager: FolderManager
    private let simulatorManager: SimulatorManager

    init(
        folderManager: FolderManager = .live,
        simulatorManager: SimulatorManager = .live
    ) {
        self.folderManager = folderManager
        self.simulatorManager = simulatorManager
    }

    func handleAction(_ action: Action) {
        switch action {
        case .installedApplicationsViewModelEvent(let event):
            handleInstalledApplicationsViewModelEvent(event)

        case .installedApplicationDetailViewEvent(let event):
            handleInstalledApplicationDetailViewEvent(event)

        case .documentFolderViewModelEvent(let event):
            handleDocumentsFolderViewModelEvent(event)
        }
    }
}

private extension InstalledApplicationsCoordinator {
    func handleInstalledApplicationsViewModelEvent(_ event: InstalledApplicationsViewModel.Event) {
        switch event {
        case .didFailToFetchInstalledApps:
            self.alert = .didFailToFetchInstalledApps

        case .didSelectApp(let installedApplication):
            destination.append(.installedApplicationDetails(installedApplication))

        case .didFailToRetrieveApplication:
            self.alert = .didFailToRetrieveApp

        case .simulatorNotBooted:
            self.alert = .simulatorNotBooted
        }
    }

    func handleInstalledApplicationDetailViewEvent(_ event: InstalledApplicationDetailViewModel.Event) {
        switch event {
        case .couldNotOpenUserDefaults:
            self.alert = .couldNotOpenUserDefaults

        case .didSelectRemoveUserDefaults(let detail):
            self.alert = .didSelectRemoveUserDefaults(detail)

        case .didSelectUninstallApplication(let detail):
            guard let selectedSimulator = simulatorManager.selectedSimulator else {
                self.alert = .noSelectedSimulator
                return
            }
            
            self.alert = .didSelectUnisntallApplication(selectedSimulator, detail)

        case .didSelectApplicationSandboxData(let installedApplication):
            guard let path = installedApplication.dataContainer else { return }
            let expandedPath = NSString(string: path).expandingTildeInPath
            let fileURL = URL(fileURLWithPath: expandedPath)
            destination.append(.folder(fileURL))

        case .didSelectOpenUserDefaults(let installedApplication):
            let result = folderManager.openUserDefaultsFolder(installedApplication)

            if case .failure = result {
				self.alert = .couldNotOpenUserDefaults
            }
        }
    }

    func handleDocumentsFolderViewModelEvent(_ event: DocumentsFolderViewModel.Event) {
        switch event {
        case .didFailToFetchFiles:
            self.alert = .didFailToFetchFiles
        case .didFailToFindSelectedFile:
            self.alert = .didFailToFindSelectedFile
        case .didFailToOpenFile:
            self.alert = .didFailToOpenFile
        case .didSelect(let fileItem):
            destination.append(.folder(fileItem.url))
        case .didSelectOpenInFinder(let fileItem):
			if case .failure = folderManager.openFile(fileItem.url) {
				self.alert = .didFailToOpenFile
			}
        }
    }
}

extension InstalledApplicationsCoordinator {
    func jdAlert(_ alert: Alert) -> JDAlert {
        return switch alert {
        case .simulatorNotBooted:
            JDAlert(
                title: "Simulator not booted",
                message: "Please boot your simulator before continuing"
            )
        case .didFailToRetrieveApp:
            JDAlert(
                title: "Failed retrieving installed application",
                message: "Please check the simulator state and try again"
            )
        case .didFailToFetchInstalledApps:
            JDAlert(title: "Failed fetching installed apps")
        case .couldNotOpenUserDefaults:
            JDAlert(title: "Unable to open User Defaults Folder")
        case .couldNotRemoveApplication:
            JDAlert(title: "Could not Remove Application")
        case .couldNotRemoveUserDefaults:
            JDAlert(title: "Could not Remove User Defaults")
        case .didSelectRemoveUserDefaults(let application):
            JDAlert(
                title: "Remove User Defaults",
                message: "Are you sure about removing the user defaults folder for this application?",
                button1: AlertButton(
                    title: "Remove",
                    action: {
                        switch self.folderManager.removeUserDefaults(application) {
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
        case .didSelectUnisntallApplication(let simulator, let details):
            JDAlert(
                title: "Remove Application from Simulator",
                message: "Are you sure about removing the application?",
                button1: AlertButton(title: "Remove") { [unowned self] in
                    switch self.simulatorManager.uninstall(
                        details,
                        simulatorID: simulator.id
                    ) {
                    case .success:
                        Task {
                            try? await Task.sleep(for: .seconds(1))

                            await MainActor.run {
                                self.alert = .didUnisntallApplication(details)
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
        case .didFailToFetchFiles:
            JDAlert(title: "Failed to Fetch Files")
        case .didFailToFindSelectedFile:
            JDAlert(title: "Failed to Find Selected File")
        case .didFailToOpenFile:
            JDAlert(title: "Failed to Open File")
        case .noSelectedSimulator:
            JDAlert(title: "No Simulator Selected")
        }
    }
}
