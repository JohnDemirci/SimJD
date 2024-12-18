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
        case didUpdateSimulatorLocation
        case failedUpdatingSimulatorLocation
        case failedToConvertMapReaderProxy

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
        .onChange(of: simManager.selectedSimulator, initial: false) { oldValue, newValue in
            if oldValue != newValue {
                dismiss()
            }
        }
        .alert(item: $alert) { alert in
            switch alert {
            case .didUpdateSimulatorLocation:
                SwiftUI.Alert(
                    title: Text("Success")
                )
            case .failedToConvertMapReaderProxy:
                SwiftUI.Alert(
                    title: Text("Failure"),
                    message: Text("Could not locate the coordinates")
                )
            case .failedUpdatingSimulatorLocation:
                SwiftUI.Alert(
                    title: Text("Could not update location")
                )
            }
        }
    }

    func handleAction(_ action: Action) {
        switch action {
        case .simulatorGeolocationViewEvent(let event):
            switch event {
            case .updatedLocation:
                self.alert = .didUpdateSimulatorLocation
            case .couldNotUpdateLocation:
                self.alert = .failedUpdatingSimulatorLocation
            case .coordinateTranslationFailed:
                self.alert = .failedToConvertMapReaderProxy
            }
        }
    }
}
