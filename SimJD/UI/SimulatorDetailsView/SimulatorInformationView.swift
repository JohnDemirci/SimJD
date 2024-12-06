//
//  SimulatorInformationView.swift
//  SimJD
//
//  Created by John Demirci on 12/1/24.
//

import SwiftUI

struct SimulatorInformationView: View {
    @Bindable private var simManager: SimulatorManager

    init(simManager: SimulatorManager) {
        self.simManager = simManager
    }

    var body: some View {
        OptionalView(simManager.selectedSimulator) { simulator in
            Text(simulator.name ?? "")
                .font(.largeTitle)

            Text(simulator.id)

            Text(simulator.deviceTypeIdentifier ?? "")
                .padding(.top, 20)

            Text(simulator.os?.name ?? "")
        }
    }
}
