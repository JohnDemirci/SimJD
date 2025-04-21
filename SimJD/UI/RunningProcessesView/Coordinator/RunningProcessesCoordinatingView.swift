//
//  RunningProcessesCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI
import Observation

struct RunningProcessesCoordinatingView: View {
    @State private var coordinator = RunningProcessesCoordinator()

    private let simManager: SimulatorManager = .live

    var body: some View {
        RunningProcessesView(
            viewModel: RunningProcessesViewModel( {
                coordinator.handleAction(.runningProcessesViewEvent($0))
            })
        )
        .nsAlert(item: $coordinator.alert) {
            switch $0 {
            case .fetchError:
                return JDAlert(title: "Unable to fetch processes")
            }
        }
    }
}
