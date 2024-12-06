//
//  InstalledApplicationDetailView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct InstalledApplicationDetailView: View {
    enum Event {
        case couldNotOpenSandboxFolder
        case couldNotOpenUserDefaults
        case didSelectRemoveUserDefaults
        case didSelectUninstallApplication(Simulator)
    }

    @Bindable private var folderManager: FolderManager
    @Bindable private var simulatorManager: SimulatorManager

    private let installedApplication: InstalledAppDetail
    private let sendEvent: (Event) -> Void

    init(
        folderManager: FolderManager,
        installedApplication: InstalledAppDetail,
        simulatorManager: SimulatorManager,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.folderManager = folderManager
        self.installedApplication = installedApplication
        self.simulatorManager = simulatorManager
        self.sendEvent = sendEvent
    }

    var body: some View {
        List {
            ListRowTapableButton("Application Sandbox Data") {
                switch folderManager.openApplicationSupport(installedApplication) {
                case .success:
                    break
                case .failure:
                    sendEvent(.couldNotOpenSandboxFolder)
                }
            }

            ListRowTapableButton("Open UserDefaults") {
                switch folderManager.openUserDefaultsFolder(installedApplication) {
                case .success:
                    break

                case .failure:
                    sendEvent(.couldNotOpenUserDefaults)
                }
            }

            ListRowTapableButton("Remove UserDefaults") {
                sendEvent(.didSelectRemoveUserDefaults)
            }

            OptionalView(simulatorManager.selectedSimulator) { simulator in
                ListRowTapableButton("Uninstall Application") {
                    sendEvent(.didSelectUninstallApplication(simulator))
                }
            }
        }
    }
}
