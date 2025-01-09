//
//  RunningProcessesCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct RunningProcessesCoordinatingView: CoordinatingView {
    enum Action {
        case runningProcessesViewEvent(RunningProcessesView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case fetchError

        var id: AnyHashable {
            "\(self)" as AnyHashable
        }
    }

    @Environment(SimulatorManager.self) private var simManager
    @State var alert: Alert?

    var body: some View {
        RunningProcessesView(
            simManager: simManager,
            sendEvent: {
                handleAction(.runningProcessesViewEvent($0))
            }
        )
        .nsAlert(item: $alert) {
            switch $0 {
            case .fetchError:
                return JDAlert(title: "Unable to fetch processes")
            }
        }
    }
}

extension RunningProcessesCoordinatingView {
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
