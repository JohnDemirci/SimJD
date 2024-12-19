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
            Grid {
                GridRow(alignment: .center) {
                    ForEach(models) { model in
                        model.view
                    }
                }
            }
        }
    }
}

private extension SimulatorActionOptionsView {
    struct ButtonModel: Identifiable {
        let assetName: String
        let action: () -> Void

        var id: String { assetName }

        @MainActor
        var view: some View {
            Button(
                action: {
                    self.action()
                },
                label: {
                    Image(assetName)
                        .resizable()
                        .frame(width: 100, height: 100)
                }
            )
            .buttonStyle(.plain)
        }
    }
}

private extension SimulatorActionOptionsView {
    private var models: [ButtonModel] {
        guard let simulator = simManager.selectedSimulator else { return [] }

        return [
            ButtonModel(assetName: "documentsFolder") {
                switch folderManager.openDocumentsFolder(simulator) {
                case .success:
                    print("Successfully opened Documents folder")
                case .failure(let error):
                    sendEvent(.didFailToOpenFolder(error))
                }
            },
            ButtonModel(assetName: "eraseContents") {
                sendEvent(.didSelectEraseData(simulator))
            },
            ButtonModel(assetName: "activeProcesses") {
                sendEvent(.didSelectRunningProcesses)
            },
            ButtonModel(assetName: "installedApplications") {
                sendEvent(.didSelectInstalledApplications)
            },
            ButtonModel(assetName: "geolocation") {
                sendEvent(.didSelectGeolocation(simulator))
            }
        ]
    }
}
