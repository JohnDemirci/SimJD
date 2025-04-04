//
//  SimulatorGeolocationCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 12/17/24.
//

import SwiftUI

struct SimulatorGeolocationCoordinatingView: View {
    @State private var coordinator = SimulatorGeolocationCoordinator()

    var body: some View {
        SimulatorGeolocationView(
            viewModel: .init(
                sendEvent: { coordinator.handleAction(.simulatorGeolocationViewModelEvent($0)) }
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .nsAlert(item: $coordinator.alert) { alert in
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
