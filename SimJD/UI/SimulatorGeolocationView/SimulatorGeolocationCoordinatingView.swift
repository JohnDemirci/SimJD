//
//  SimulatorGeolocationCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 12/17/24.
//

import SwiftUI

@Observable
final class SimulatorGeolocationCoordinatingViewModel {
    enum Action {
        case simulatorGeolocationViewEvent(SimulatorGeolocationView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case didFailCoordinateProxy
        case didFailUpdateLocation
        case didUpdateLocation

        var id: AnyHashable {
            self
        }
    }

    var alert: Alert?

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

struct SimulatorGeolocationCoordinatingView: CoordinatingView {
    private let simManager: SimulatorManager = .live
    @State private var viewModel = SimulatorGeolocationCoordinatingViewModel()

    var body: some View {
        SimulatorGeolocationView { event in
            viewModel.handleAction(.simulatorGeolocationViewEvent(event))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .nsAlert(item: $viewModel.alert) { alert in
            switch alert {
            case .didFailCoordinateProxy:
                return JDAlert(
                    title: "Failure",
                    message: "Could not locate the coordinates"
                )

            case .didFailUpdateLocation:
                return JDAlert(title: "Could not update location")

            case .didUpdateLocation:
                return JDAlert(title: "Success")
            }
        }
    }
}
