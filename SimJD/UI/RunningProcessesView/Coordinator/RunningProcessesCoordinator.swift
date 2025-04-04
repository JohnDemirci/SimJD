//
//  RunningProcessesCoordinator.swift
//  SimJD
//
//  Created by John Demirci on 4/3/25.
//

import SwiftUI

@MainActor
@Observable
final class RunningProcessesCoordinator {
    enum Action {
        case runningProcessesViewEvent(RunningProcessesViewModel.Event)
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
