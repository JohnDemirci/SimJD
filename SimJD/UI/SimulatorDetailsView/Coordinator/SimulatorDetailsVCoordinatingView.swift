//
//  SimulatorDetailsViewCoordinator.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SimulatorDetailsVCoordinatingView: View {
    @State private var coordinator = SimulatorDetailsCoordinator()

    private let simManager: SimulatorManager = .live

    @State var alert: Alert?

    var body: some View {
        SimulatorDetailsView(
            viewModel: .init(sendEvent: { event in
                coordinator.handleAction(.simulatorDetailsViewEvent(event))
            })
        )
        .nsAlert(item: $coordinator.alert) {
            coordinator.getJDAlert(for: $0)
        }
    }
}
