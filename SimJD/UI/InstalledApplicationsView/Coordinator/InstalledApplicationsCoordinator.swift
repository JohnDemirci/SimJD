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
        case installedApplicationMore(InstalledAppDetail)
    }

    enum Action {
        case documentFolderViewModelEvent(DocumentsFolderViewModel.Event)
        case installedApplicationDetailViewEvent(InstalledApplicationDetailViewModel.Event)
        case installedApplicationMoreViewModelEvent(InstalledApplicationMoreViewModel.Event)
        case installedApplicationsViewModelEvent(InstalledApplicationsViewModel.Event)
    }

    enum Alert: Hashable, Identifiable {
        case couldNotFindPathToApplication
        case couldNotOpenUserDefaults
        case couldNotRemoveApplication
        case couldNotRemoveUserDefaults
        case didFailToFetchFiles
        case didFailToFetchInstalledApps
        case didFailToFindSelectedFile
        case didFailToOpenFile
        case didFailToRetrieveApp
        case didRemoveUserDefaults
        case didSelectRemoveUserDefaults(InstalledAppDetail)
        case didSelectUnisntallApplication(Simulator, InstalledAppDetail)
        case didUnisntallApplication(InstalledAppDetail)
        case noSelectedSimulator
        case simulatorNotBooted

        var id: AnyHashable { self }
    }

    private let folderManager: FolderManager
    private let simulatorManager: SimulatorManager

    var alert: Alert?
    var destination: [Destination] = []

    init(
        folderManager: FolderManager = .live,
        simulatorManager: SimulatorManager = .live
    ) {
        self.folderManager = folderManager
        self.simulatorManager = simulatorManager
    }

    func handleAction(_ action: Action) {
        switch action {
        case .documentFolderViewModelEvent(let event):
            handleDocumentsFolderViewModelEvent(event)

        case .installedApplicationDetailViewEvent(let event):
            handleInstalledApplicationDetailViewEvent(event)

        case .installedApplicationMoreViewModelEvent(let event):
            handleInstalledApplicationMoreViewModelEvent(event)

        case .installedApplicationsViewModelEvent(let event):
            handleInstalledApplicationsViewModelEvent(event)
        }
    }
}

private extension InstalledApplicationsCoordinator {
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

    func handleInstalledApplicationDetailViewEvent(_ event: InstalledApplicationDetailViewModel.Event) {
        switch event {
        case .couldNotOpenUserDefaults:
            self.alert = .couldNotOpenUserDefaults

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

        case .didSelectInfoPlist(let details):
            guard let appPath = details.path else {
                self.alert = .couldNotFindPathToApplication
                return
            }

            let plistPath = URL(fileURLWithPath: appPath).appendingPathComponent("Info.plist")
            switch folderManager.openFile(plistPath) {
            case .success:
                break
            case .failure:
                self.alert = .didFailToOpenFile
            }

        case .didSelectMore(let detail):
            self.destination.append(.installedApplicationMore(detail))

        case .didSelectRemoveUserDefaults(let detail):
            self.alert = .didSelectRemoveUserDefaults(detail)

        case .didSelectUninstallApplication(let detail):
            guard let selectedSimulator = simulatorManager.selectedSimulator else {
                self.alert = .noSelectedSimulator
                return
            }

            self.alert = .didSelectUnisntallApplication(selectedSimulator, detail)
        }
    }

    func handleInstalledApplicationMoreViewModelEvent(_ event: InstalledApplicationMoreViewModel.Event) {
        switch event {
        case .didSelectCachedBuildFolder(let fileItem, let detail):
            let filesImDirectory = try! FileManager
                .default
                .contentsOfDirectory(at: fileItem.url, includingPropertiesForKeys: [.nameKey])

            let appBinary = filesImDirectory.first { (url: URL) in
                url.absoluteString.localizedStandardContains(fileItem.name)
            }

            guard let appBinary else { return }
            guard let selectedSimulator = simulatorManager.selectedSimulator else { return }

            let _ = Shell.shared.execute(.installApp(selectedSimulator.id, appBinary.path()))
            let _ = Shell.shared.execute(.launchApp(selectedSimulator.id, detail.bundleIdentifier!))
        }
    }

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
}

extension InstalledApplicationsCoordinator {
    func jdAlert(_ alert: Alert) -> JDAlert {
        return switch alert {
        case .couldNotFindPathToApplication:
            JDAlert(title: "Could nto find the application path the installed application")
        case .couldNotOpenUserDefaults:
            JDAlert(title: "Unable to open User Defaults Folder")
        case .couldNotRemoveApplication:
            JDAlert(title: "Could not Remove Application")
        case .couldNotRemoveUserDefaults:
            JDAlert(title: "Could not Remove User Defaults")
        case .didFailToFetchFiles:
            JDAlert(title: "Failed to Fetch Files")
        case .didFailToFetchInstalledApps:
            JDAlert(title: "Failed fetching installed apps")
        case .didFailToFindSelectedFile:
            JDAlert(title: "Failed to Find Selected File")
        case .didFailToOpenFile:
            JDAlert(title: "Failed to Open File")
        case .didFailToRetrieveApp:
            JDAlert(
                title: "Failed retrieving installed application",
                message: "Please check the simulator state and try again"
            )
        case .didRemoveUserDefaults:
            JDAlert(title: "User Defaults Removed")
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
                        simulator: simulator
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
        case .noSelectedSimulator:
            JDAlert(title: "No Simulator Selected")
        case .simulatorNotBooted:
            JDAlert(
                title: "Simulator not booted",
                message: "Please boot your simulator before continuing"
            )
        }
    }
}
