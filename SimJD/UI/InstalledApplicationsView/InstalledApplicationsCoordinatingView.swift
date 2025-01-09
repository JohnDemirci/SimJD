//
//  InstalledApplicationsCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct InstalledApplicationsCoordinatingView: CoordinatingView {
    enum Action {
        case installedApplicationsViewEvent(InstalledApplicationsView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case didFailToFetchInstalledApps
        case didFailToRetrieveApp

        var id: AnyHashable {
            "\(self)" as AnyHashable
        }
    }

    @Environment(FolderManager.self) private var folderManager: FolderManager
    @Environment(SimulatorManager.self) private var simulatorManager: SimulatorManager
    @EnvironmentObject private var navigator: FileSystemNavigator

    @State var alert: Alert?

    var body: some View {
        InstalledApplicationsView(
            sendEvent: { handleAction(.installedApplicationsViewEvent($0)) }
        )
        .alert(item: $alert) {
            switch $0 {
            case .didFailToFetchInstalledApps:
                SwiftUI.Alert(title: Text("Could not fetch installed apps"))

            case .didFailToRetrieveApp:
                SwiftUI.Alert(title: Text("Could not retrieve installed application"))
            }
        }
    }
}

extension InstalledApplicationsCoordinatingView {
    func handleAction(_ action: Action) {
        switch action {
        case .installedApplicationsViewEvent(let event):
            switch event {
            case .didFailToFetchInstalledApps:
                self.alert = .didFailToFetchInstalledApps

            case .didSelectApp(let installedApplication):
                navigator.add(.installedApplicationDetails(installedApplication))

            case .didFailToRetrieveApplication:
                self.alert = .didFailToRetrieveApp
            }
        }
    }
}
