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
        case couldNotFetchInstalledApps

        var id: AnyHashable {
            "\(self)" as AnyHashable
        }
    }

    enum Destination: Hashable {
        case installedAppDetailView(InstalledAppDetail, Binding<[InstalledAppDetail]>)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .installedAppDetailView(let installedApp, let installedApps):
                hasher.combine(installedApp)
                hasher.combine(installedApps.wrappedValue)
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.installedAppDetailView(let lhsInstalledApp, let lhsInstalledApps), .installedAppDetailView(let rhsInstalledApp, let rhsInstalledApps)):

                return lhsInstalledApp == rhsInstalledApp && lhsInstalledApps.wrappedValue == rhsInstalledApps.wrappedValue
            }
        }
    }

    @Bindable private var folderManager: FolderManager
    @Bindable private var simulatorManager: SimulatorManager

    @State var alert: Alert?
    @State var destination: Destination?

    init(
        folderManager: FolderManager,
        simulatorManager: SimulatorManager
    ) {
        self.folderManager = folderManager
        self.simulatorManager = simulatorManager
    }

    var body: some View {
        InstalledApplicationsView(
            folderManager: folderManager,
            simulatorManager: simulatorManager,
            sendEvent: { handleAction(.installedApplicationsViewEvent($0)) }
        )
        .alert(item: $alert) {
            switch $0 {
            case .couldNotFetchInstalledApps:
                SwiftUI.Alert(title: Text("Could not fetch installed apps"))
            }
        }
        .navigationDestination(item: $destination) {
            switch $0 {
            case .installedAppDetailView(let installedApplication, let $bindingApplications):
                InstalledApplicationDetailCoordinatingView(
                    folderManager: folderManager,
                    installedApplication: installedApplication,
                    installedApplications: $bindingApplications,
                    simulatorManager: simulatorManager
                )
            }
        }
    }
}

extension InstalledApplicationsCoordinatingView {
    func handleAction(_ action: Action) {
        switch action {
        case .installedApplicationsViewEvent(let event):
            switch event {
            case .couldNotFetchInstalledApps:
                self.alert = .couldNotFetchInstalledApps

            case .didSelectApp(let installedApplication, let $bindingApplications):
                navigate(to: .installedAppDetailView(installedApplication, $bindingApplications))
            }
        }
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .installedAppDetailView(let installedApp, let $bindingApplications):
            self.destination = .installedAppDetailView(installedApp, $bindingApplications)
        }
    }
}
