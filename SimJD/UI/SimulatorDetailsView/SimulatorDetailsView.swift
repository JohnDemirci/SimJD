//
//  SimulatorDetailsView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import Combine
import SwiftUI

struct SimulatorDetailsView: View {
    enum Action {
        case simulatorActionOptionsViewEvent(SimulatorActionOptionsView.Event)
        case deviceStatusViewEvent(DeviceStatusView.Event)
    }

    enum Event {
        case couldNotEraseContent(Failure)
        case couldNotOpenFolder(Failure)
        case didSelectDeleteSimulator(Simulator)
        case didSelectEraseData(Simulator)
        case didSelectInstalledApplications
        case didSelectRunningProcesses
        case didSelectGeolocation(Simulator)
    }

    @Bindable private var simManager: SimulatorManager
    @Bindable private var folderManager: FolderManager
    
    private let sendEvent: (Event) -> Void

    init(
        folderManager: FolderManager,
        simManager: SimulatorManager,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.simManager = simManager
        self.folderManager = folderManager
        self.sendEvent = sendEvent
    }

    var body: some View {
        HStack {
            DeviceStatusView(simManager: simManager) {
                handleAction(.deviceStatusViewEvent($0))
            }

            VStack {
                SimulatorInformationView(simManager: simManager)
                SimulatorActionOptionsView(
                    folderManager: folderManager,
                    simManager: simManager,
                    sendEvent: {
                        handleAction(.simulatorActionOptionsViewEvent($0))
                    }
                )
                Spacer()
            }
            .textSelection(.enabled)
            .padding()
        }
    }
}

extension SimulatorDetailsView {
    func handleAction(_ action: Action) {
        switch action {
        case .deviceStatusViewEvent(let event):
            handleDeviceStatusEvent(event)

        case .simulatorActionOptionsViewEvent(let event):
            handleSimulatorActionOptionsViewEvent(event)
        }
    }
}

private extension SimulatorDetailsView {
    func handleDeviceStatusEvent(_ event: DeviceStatusView.Event) {
        switch event {
        case .didSelectDeleteSimulator(let simulator):
            sendEvent(.didSelectDeleteSimulator(simulator))
        }
    }

    func handleSimulatorActionOptionsViewEvent(_ event: SimulatorActionOptionsView.Event) {
        switch event {
        case .couldNotOpenFolder(let error):
            sendEvent(.couldNotOpenFolder(error))

        case .didSelectEraseData(let simulator):
            sendEvent(.didSelectEraseData(simulator))

        case .didSelectRunningProcesses:
            sendEvent(.didSelectRunningProcesses)

        case .didSelectInstalledApplications:
            sendEvent(.didSelectInstalledApplications)

        case .didSelectGeolocation(let simulator):
            sendEvent(.didSelectGeolocation(simulator))
        }
    }
}
