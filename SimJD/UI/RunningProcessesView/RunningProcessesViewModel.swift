//
//  RunningProcessesViewModel.swift
//  SimJD
//
//  Created by John Demirci on 4/3/25.
//

import SwiftUI

@MainActor
@Observable
final class RunningProcessesViewModel {
    enum Event {
        case didFailToFetchProcesses
    }

    private let simManager: SimulatorManager
    private let sendEvent: (Event) -> Void

    init(
        simManager: SimulatorManager = .live,
        _ sendEvent: @escaping (Event) -> Void
    ) {
        self.simManager = simManager
        self.sendEvent = sendEvent
        observeChanges()
    }

    var processes: [ProcessInfo] {
        guard let selectedSimulator else { return [] }
        return simManager.processes[selectedSimulator.id] ?? []
    }

    func emptyProcesses() {
        guard let selectedSimulator else { return }
        simManager.openSimulator(selectedSimulator)
        fetchRunningProcesses()
    }
}

private extension RunningProcessesViewModel {
    var selectedSimulator: Simulator? {
        simManager.selectedSimulator
    }

    func observeChanges() {
        withObservationTracking {
            _ = simManager.selectedSimulator
        } onChange: {
            Task { @MainActor [weak self] in
                self?.fetchRunningProcesses()
                self?.observeChanges()
            }
        }
    }

    func fetchRunningProcesses() {
        guard let selectedSimulator = simManager.selectedSimulator else { return }
        switch simManager.fetchRunningProcesses(for: selectedSimulator) {
        case .success:
            break
        case .failure:
            sendEvent(.didFailToFetchProcesses)
        }
    }
}
