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
    enum Event {
        case didFailToFetchInstalledApps(Failure)
        case didFailToRetrieveApplication
        case didSelectApp(InstalledAppDetail)
        case simulatorNotBooted
    }

    private let simulatorManager: SimulatorManager
    private let sendEvent: (Event) -> Void

    var selectedApp: InstalledAppDetail.ID?
    private(set) var installedApplications: [InstalledAppDetail]?

    init(
        simulatorManager: SimulatorManager = .live,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.simulatorManager = simulatorManager
        self.sendEvent = sendEvent
    }
}

// computed properties
extension InstalledApplicationsViewModel {
    var selectedSimulator: Simulator? {
        simulatorManager.selectedSimulator
    }
}

// actions
extension InstalledApplicationsViewModel {
    func fetchInstalledApplications() {
        guard let selectedSimulator else { return }

        switch simulatorManager.fetchInstalledApplications(for: selectedSimulator) {
        case .success:
            if selectedSimulator.state != "Booted" {
                sendEvent(.simulatorNotBooted)
            }
            
            installedApplications = simulatorManager.installedApplications[selectedSimulator.id]

        case .failure(let error):
            sendEvent(.didFailToFetchInstalledApps(error))
            installedApplications = nil
        }
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

    func didSelectCopyApplicationPath(_ apps: Set<InstalledAppDetail.ID>) {
        guard
            let installedApp = getInstalledAppFromSelections(apps),
            let dataContainer = installedApp.dataContainer
        else {
            return
        }

        copyToClipboard(dataContainer)
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

    func didSelectCopyBundlePath(_ apps: Set<InstalledAppDetail.ID>) {
        guard
            let installedApp = getInstalledAppFromSelections(apps),
            let bundle = installedApp.bundle
        else {
            return
        }

        copyToClipboard(bundle)
    }

    func didSelectApp(_ apps: Set<InstalledAppDetail.ID>) {
        guard let installedApp = getInstalledAppFromSelections(apps) else {
            return
        }

        sendEvent(.didSelectApp(installedApp))
    }

    func fetchAndObserve() {
        self.fetchInstalledApplications()
        self.startObservation()
    }
}

// private
private extension InstalledApplicationsViewModel {
    // TODO: - use protocols to make clipboard testable

    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
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
