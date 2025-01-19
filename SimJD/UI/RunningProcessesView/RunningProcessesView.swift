//
//  RunningProcessesView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct RunningProcessesView: View {
    enum Event {
        case didFailToFetchProcesses
    }

    @Environment(SimulatorManager.self) private var simManager: SimulatorManager

    private let sendEvent: (Event) -> Void

    init(sendEvent: @escaping (Event) -> Void) {
        self.sendEvent = sendEvent
    }

    var body: some View {
        List {
            OptionalView(
                data: simManager.selectedSimulator,
                unwrappedData: { selectedSimulator in
                    OptionalView(
                        data: simManager.processes[selectedSimulator.id],
                        unwrappedData: { processes in
                            ForEach(processes) { process in
                                Text(process.label)
                            }
                            .inCase(simManager.processes[selectedSimulator.id] == []) {
                                NoProcessView {
                                    simManager.openSimulator(selectedSimulator)
                                    handleFetchProcesses()
                                }
                            }
                        },
                        placeholderView: {
                            NoProcessView {
                                simManager.openSimulator(selectedSimulator)
                                handleFetchProcesses()
                            }
                        }
                    )
                },
                placeholderView: {
                    Text("There is no selected Simulator")
                }
            )
        }
        .scrollContentBackground(.hidden)
        .onChange(of: simManager.selectedSimulator, initial: true) {
            handleFetchProcesses()
        }
    }
}

private extension RunningProcessesView {
    func handleFetchProcesses() {
        guard let selectedSimulator = simManager.selectedSimulator else { return }

        switch simManager.fetchRunningProcesses(for: selectedSimulator) {
        case .success:
            break

        case .failure:
            sendEvent(.didFailToFetchProcesses)
        }
    }
}

private struct NoProcessView: View {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        VStack {
            Text("Currently There are no processes, check if the simulator is active")
            Button("turn on this simulator") {
                withAnimation {
                    action()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
