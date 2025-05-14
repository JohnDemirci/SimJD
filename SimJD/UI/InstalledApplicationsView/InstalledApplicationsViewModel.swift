//
//  InstalledApplicationsViewModel.swift
//  SimJD
//
//  Created by John Demirci on 4/4/25.
//

import SwiftUI

@MainActor
@Observable
final class InstalledApplicationsViewModel {
    enum Event: Equatable {
        case didFailToFetchInstalledApps(Failure)
        case didFailToRetrieveApplication
        case didSelectApp(InstalledAppDetail)
        case simulatorNotBooted
    }

    private let copyBoard: CopyBoardProtocol
    private let sendEvent: (Event) -> Void
    private let simulatorManager: SimulatorManager

    private(set) var installedApplications: [InstalledAppDetail]?

    var selectedApp: InstalledAppDetail.ID?

    init(
        copyBoard: CopyBoardProtocol = CopyBoard(),
        simulatorManager: SimulatorManager = .live,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.copyBoard = copyBoard
        self.sendEvent = sendEvent
        self.simulatorManager = simulatorManager
    }
}

extension InstalledApplicationsViewModel {
    var selectedSimulator: Simulator? {
        simulatorManager.selectedSimulator
    }
}

extension InstalledApplicationsViewModel {
    func fetchInstalledApplications() {
        guard let selectedSimulator else {
            self.installedApplications = nil
            return
        }

        self.installedApplications = simulatorManager.installedApplications[selectedSimulator.id]
    }

    func didSelectApp(_ apps: Set<InstalledAppDetail.ID>) {
        guard let installedApp = getInstalledAppFromSelections(apps) else {
            return
        }

        sendEvent(.didSelectApp(installedApp))
    }

    func didSelectCopyApplicationPath(_ apps: Set<InstalledAppDetail.ID>) {
        guard
            let installedApp = getInstalledAppFromSelections(apps),
            let dataContainer = installedApp.dataContainer
        else {
            return
        }

        copyToClipboard(dataContainer)
    }

    func didSelectCopyBundleID(_ apps: Set<InstalledAppDetail.ID>) {
        guard
            let installedApp = getInstalledAppFromSelections(apps),
            let bundleID = installedApp.bundleIdentifier
        else {
            return
        }

        copyToClipboard(bundleID)
    }

    func didSelectCopyBundlePath(_ apps: Set<InstalledAppDetail.ID>) {
        guard
            let installedApp = getInstalledAppFromSelections(apps),
            let bundle = installedApp.bundle
        else {
            return
        }

        copyToClipboard(bundle)
    }

    func didSelectCopyDataContainerPath(_ apps: Set<InstalledAppDetail.ID>) {
        guard
            let installedApp = getInstalledAppFromSelections(apps),
            let path = installedApp.path
        else {
            return
        }

        copyToClipboard(path)
    }

    func fetchAndObserve() {
        self.fetchInstalledApplications()
        self.startObservation()
    }
}

private extension InstalledApplicationsViewModel {
    func copyToClipboard(_ text: String) {
        copyBoard.clear()
        copyBoard.copy(text)
    }

    func getInstalledAppFromSelections(
        _ selections: Set<InstalledAppDetail.ID>
    ) -> InstalledAppDetail? {
        guard
            let selection = selections.first,
            let installedApps = installedApplications,
            let selectedApp = installedApps.first(where: { $0.bundleIdentifier == selection })
        else {
            sendEvent(.didFailToRetrieveApplication)
            return nil
        }

        return selectedApp
    }

    func startObservation() {
        withObservationTracking {
            _ = simulatorManager.selectedSimulator
        } onChange: {
            Task { @MainActor [weak self] in
                self?.fetchInstalledApplications()
                self?.startObservation()
            }
        }
    }
}
