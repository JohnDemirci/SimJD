//
//  RunningProcessesCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

@MainActor
@Observable
final class RunningProcessesCoordinatingViewModel {
    enum Action {
        case runningProcessesViewEvent(RunningProcessesView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case fetchError

        var id: AnyHashable { self }
    }

    var alert: Alert?

    func handleAction(_ action: Action) {
        switch action {
        case .runningProcessesViewEvent(let event):
            switch event {
            case .didFailToFetchProcesses:
                self.alert = .fetchError
            }
        }
    }
}

struct RunningProcessesCoordinatingView: CoordinatingView {
    @Environment(SimulatorManager.self) private var simManager
    @State private var viewModel = RunningProcessesCoordinatingViewModel()

    var body: some View {
        RunningProcessesView(
            sendEvent: {
                viewModel.handleAction(.runningProcessesViewEvent($0))
            }
        )
        .nsAlert(item: $viewModel.alert) {
            switch $0 {
            case .fetchError:
                return JDAlert(title: "Unable to fetch processes")
            }
        }
    }
}
