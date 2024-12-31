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
        case installedAppsView

        func hash(into hasher: inout Hasher) {
            switch self {
            case .installedAppDetailView(let installedApp, let installedApps):
                hasher.combine(installedApp)
                hasher.combine(installedApps.wrappedValue)
            case .installedAppsView:
                hasher.combine(Self.installedAppsView)
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.installedAppDetailView(let lhsInstalledApp, let lhsInstalledApps), .installedAppDetailView(let rhsInstalledApp, let rhsInstalledApps)):

                return lhsInstalledApp == rhsInstalledApp && lhsInstalledApps.wrappedValue == rhsInstalledApps.wrappedValue

            case (.installedAppsView, .installedAppsView):
                return true

            default:
                return false
            }
        }
    }

    @Bindable private var folderManager: FolderManager
    @Bindable private var simulatorManager: SimulatorManager

    @State var alert: Alert?
    @State var destination: Destination? = .installedAppsView

    init(
        folderManager: FolderManager,
        simulatorManager: SimulatorManager
    ) {
        self.folderManager = folderManager
        self.simulatorManager = simulatorManager
    }

    var body: some View {
        switch destination {
        case .installedAppDetailView(let detail, let $details):
            InstalledApplicationDetailCoordinatingView(
                folderManager: folderManager,
                installedApplication: detail,
                installedApplications: $details,
                simulatorManager: simulatorManager
            )

        case .installedAppsView:
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
        case .none:
            EmptyView()
        }
    }
}

extension InstalledApplicationsCoordinatingView {
    func handleAction(_ action: Action) {
        switch action {
        case .installedApplicationsViewEvent(let event):
            switch event {
            case .didFailToFetchInstalledApps:
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
        case .installedAppsView:
            self.destination = .installedAppsView
        }
    }
}
