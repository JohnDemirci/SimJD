//
//  RunningProcessesView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct RunningProcessesView: View {
    enum Event {
        case couldNotFetchProcesses
    }

    @Bindable private var simManager: SimulatorManager
    @State private var processes: [ProcessInfo] = []

    private let sendEvent: (Event) -> Void

    init(
        simManager: SimulatorManager,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.simManager = simManager
        self.sendEvent = sendEvent
    }

    var body: some View {
        List {
            Section("Processes") {
                ForEach(processes) { process in
                    Text(process.label)
                }
            }
        }
        .inCase(processes.isEmpty) {
            Text("No Active Processes")
        }
        .onChange(of: simManager.selectedSimulator, initial: true) {
            guard let newSim = simManager.selectedSimulator else { return }

            switch simManager.fetchRunningProcesses(for: newSim) {
            case .success(let processes):
                withAnimation {
                    self.processes = processes
                }

            case .failure(let error):
                print(error)
                sendEvent(.couldNotFetchProcesses)
            }
        }
    }
}
