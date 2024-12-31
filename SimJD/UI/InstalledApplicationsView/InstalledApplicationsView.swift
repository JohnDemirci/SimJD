//
//  InstalledApplicationsView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct InstalledApplicationsView: View {
    enum Event {
        case didFailToFetchInstalledApps(Failure)
        case didSelectApp(InstalledAppDetail, Binding<[InstalledAppDetail]>)
    }

    @Bindable private var folderManager: FolderManager
    @Bindable private var simulatorManager: SimulatorManager

    @State private var installedApplications: [InstalledAppDetail] = []

    private let sendEvent: (Event) -> Void

    init(
        folderManager: FolderManager,
        simulatorManager: SimulatorManager,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.folderManager = folderManager
        self.simulatorManager = simulatorManager
        self.sendEvent = sendEvent
    }

    var body: some View {
        List {
            ForEach(installedApplications, id: \.self) { installedApp in
                OptionalView(installedApp.displayName) { appName in
                    ListRowTapableButton(appName) {
                        sendEvent(.didSelectApp(installedApp, $installedApplications))
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .inCase(installedApplications.isEmpty) {
            Text("Simulator is not Active")
        }
        .inCase(simulatorManager.selectedSimulator == nil) {
            Text("Please Select a Simulator")
        }
        .onChange(of: simulatorManager.selectedSimulator, initial: true) {
            guard let selectedSimulator = simulatorManager.selectedSimulator else { return }

            switch simulatorManager.fetchInstalledApplications(for: selectedSimulator) {
            case .success(let installedApplications):
                withAnimation {
                    self.installedApplications = installedApplications
                }

            case .failure(let error):
                sendEvent(.didFailToFetchInstalledApps(error))
            }
        }
    }
}
