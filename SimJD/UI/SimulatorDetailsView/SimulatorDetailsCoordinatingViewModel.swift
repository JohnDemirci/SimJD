//
//  SimulatorDetailsCoordinatingViewModel.swift
//  SimJD
//
//  Created by John Demirci on 3/29/25.
//

import SwiftUI

@MainActor
@Observable
final class SimulatorDetailsCoordinatingViewModel {
    enum Action {
        case simulatorDetailsViewEvent(SimulatorDetailsView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case didDeleteSimulator
        case didFailToDeleteSimulator
        case didFailToEraseContents
        case didSelectDeleteSimulator(Simulator)
        case didSelectEraseData(Simulator)

        var id: AnyHashable { self }
    }

    var alert: Alert?

    func handleAction(_ action: Action) {
        switch action {
        case .simulatorDetailsViewEvent(let event):
            switch event {
            case .didSelectDeleteSimulator(let simulator):
                self.alert = .didSelectDeleteSimulator(simulator)
            case .didSelectEraseContentAndSettings(let simulator):
                self.alert = .didSelectEraseData(simulator)
            }
        }
    }
}
