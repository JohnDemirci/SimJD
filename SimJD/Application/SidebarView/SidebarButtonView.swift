//
//  SidebarButtonView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SidebarButtonView: View {
    @Environment(SimulatorManager.self) var manager: SimulatorManager
    let simulator: Simulator

    init(simulator: Simulator) {
        self.simulator = simulator
    }

    var body: some View {
        HStack {
            Image(systemName: simulator.deviceImage?.systemImage ?? "iphone")
                .font(.title)

            Text(simulator.name ?? "")

            Spacer()

            Circle()
                .fill(simulator.state == "Booted" ? Color.green : Color.red)
                .frame(width: 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            manager.selectedSimulator?.id == simulator.id ? Color.brown.opacity(0.3) : .clear
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            withAnimation {
                manager.didSelectSimulator(simulator)
            }
        }
    }
}
