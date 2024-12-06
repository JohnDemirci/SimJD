//
//  DeviceStatusView.swift
//  SimJD
//
//  Created by John Demirci on 12/1/24.
//

import SwiftUI

struct DeviceStatusView: View {
    enum Event {
        case didSelectDeleteSimulator(Simulator)
    }

    @Bindable private var simManager: SimulatorManager
    private let sendEvent: (Event) -> Void

    init(
        simManager: SimulatorManager,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.simManager = simManager
        self.sendEvent = sendEvent
    }

    var body: some View {
        OptionalView(simManager.selectedSimulator) { simulator in
            VStack {
                Image(systemName: simulator.deviceImage?.systemImage ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 150, alignment: .center)
                    .foregroundStyle(simulator.state == "Booted" ? .green : .gray)

                Button(simulator.state == "Booted" ? "Shutdown" : "Boot") {
                    if simulator.state == "Booted" {
                        simManager.shutdownSimulator(simulator)
                    } else if simulator.state == "Shutdown" {
                        simManager.openSimulator(simulator)
                    }
                }

                Button("Delete", role: .destructive) {
                    sendEvent(.didSelectDeleteSimulator(simulator))
                }
                Spacer()
            }
            .font(.title)
            .padding()
        }
    }
}
