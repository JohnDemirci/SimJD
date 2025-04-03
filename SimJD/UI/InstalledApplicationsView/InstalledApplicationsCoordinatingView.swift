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
        case simulatorNotBooted

        var id: AnyHashable { self }
    }

    private let folderManager: FolderManager = .live
    private let simulatorManager: SimulatorManager = .live
    
    @EnvironmentObject private var navigator: FileSystemNavigator

    @State var alert: Alert?

    var body: some View {
        InstalledApplicationsView(
            sendEvent: { handleAction(.installedApplicationsViewEvent($0)) }
        )
        .nsAlert(item: $alert) { item in
            return switch item {
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

            case .simulatorNotBooted:
                self.alert = .simulatorNotBooted
            }
        }
    }
}
