//
//  SimulatorGeolocationCoordinator.swift
//  SimJD
//
//  Created by John Demirci on 4/3/25.
//

import SwiftUI

@Observable
final class SimulatorGeolocationCoordinator {
    enum Action {
        case simulatorGeolocationViewModelEvent(SimulatorGeolocationViewModel.Event)
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
        case .simulatorGeolocationViewModelEvent(let event):
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
