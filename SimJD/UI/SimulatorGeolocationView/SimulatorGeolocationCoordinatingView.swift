//
//  SimulatorGeolocationCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 12/17/24.
//

import SwiftUI

struct SimulatorGeolocationCoordinatingView: CoordinatingView {
    enum Action {
        case simulatorGeolocationViewEvent(SimulatorGeolocationView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case didFailCoordinateProxy
        case didFailUpdateLocation
        case didUpdateLocation

        var id: AnyHashable {
            "\(self)" as AnyHashable
        }
    }

    @Bindable var simManager: SimulatorManager
    @Environment(\.dismiss) private var dismiss
    @State var alert: Alert?

    var body: some View {
        SimulatorGeolocationView(simManager: simManager) { event in
            handleAction(.simulatorGeolocationViewEvent(event))
        }
        .alert(item: $alert) { alert in
            switch alert {
            case .didFailCoordinateProxy:
                SwiftUI.Alert(
                    title: Text("Failure"),
                    message: Text("Could not locate the coordinates")
                )

            case .didFailUpdateLocation:
                SwiftUI.Alert(
                    title: Text("Could not update location")
                )

            case .didUpdateLocation:
                SwiftUI.Alert(
                    title: Text("Success")
                )
            }
        }
        .onChange(of: simManager.selectedSimulator, initial: false) {
            if $0 != $1 {
                dismiss()
            }
        }
    }
}

extension SimulatorGeolocationCoordinatingView {
    func handleAction(_ action: Action) {
        switch action {
        case .simulatorGeolocationViewEvent(let event):
            switch event {
            case .didFailCoordinateProxy:
                self.alert = .didFailCoordinateProxy

            case .didFailUpdateLocation:
                self.alert = .didFailUpdateLocation

            case .didUpdateLocation:
                self.alert = .didUpdateLocation
            }
        }
    }
}
