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

    @Bindable private var simManager: SimulatorManager
    @State var alert: Alert?

    init(simManager: SimulatorManager) {
        self.simManager = simManager
    }

    var body: some View {
        RunningProcessesView(
            simManager: simManager,
            sendEvent: {
                handleAction(.runningProcessesViewEvent($0))
            }
        )
        .alert(item: $alert) {
            switch $0 {
            case .fetchError:
                SwiftUI.Alert(title: Text("Unable to fetch processes"))
            }
        }
    }
}

extension RunningProcessesCoordinatingView {
    func handleAction(_ action: Action) {
        switch action {
        case .runningProcessesViewEvent(let event):
            switch event {
            case .couldNotFetchProcesses:
                self.alert = .fetchError
            }
        }
    }
}
