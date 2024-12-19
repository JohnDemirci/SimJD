//
//  SimulatorActionsView.swift
//  SimJD
//
//  Created by John Demirci on 12/1/24.
//

import SwiftUI

struct SimulatorActionOptionsView: View {
    enum Event {
        case didFailToOpenFolder(Failure)
        case didSelectEraseData(Simulator)
        case didSelectGeolocation(Simulator)
        case didSelectInstalledApplications
        case didSelectRunningProcesses
    }

    @Bindable private var folderManager: FolderManager
    @Bindable private var simManager: SimulatorManager

    private let sendEvent: (Event) -> Void

    init(
        folderManager: FolderManager,
        simManager: SimulatorManager,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.folderManager = folderManager
        self.simManager = simManager
        self.sendEvent = sendEvent
    }

    var body: some View {
        OptionalView(simManager.selectedSimulator) { simulator in
            List {
                ListRowTapableButton("Documents") {
                    switch folderManager.openDocumentsFolder(simulator) {
                    case .success:
                        print("Successfully opened Documents folder")
                    case .failure(let error):
                        sendEvent(.didFailToOpenFolder(error))
                    }
                }

                ListRowTapableButton("Erase Data") {
                    sendEvent(.didSelectEraseData(simulator))
                }

                ListRowTapableButton("Active Processes") {
                    sendEvent(.didSelectRunningProcesses)
                }

                ListRowTapableButton("Installed Applications") {
                    sendEvent(.didSelectInstalledApplications)
                }

                ListRowTapableButton("Geolocation") {
                    sendEvent(.didSelectGeolocation(simulator))
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}
