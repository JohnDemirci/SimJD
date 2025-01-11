//
//  SidebarButtonView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SidebarButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(SimulatorManager.self) var manager: SimulatorManager
    let simulator: Simulator

    var systemBackground: Color {
        colorScheme == .dark ? Color.black : Color.white
    }

    var mainColor: Color {
        colorScheme == .light ? Color.init(nsColor: .brown).opacity(0.2) :
            Color.init(nsColor: .systemBrown)
    }

    init(simulator: Simulator) {
        self.simulator = simulator
    }

    var body: some View {
        Button(
            action: {
                withAnimation {
                    manager.didSelectSimulator(simulator)
                }
            },
            label: {
                HStack {
                    Image(systemName: simulator.deviceImage?.systemImage ?? "iphone")
                        .font(.title)

                    Text(simulator.name ?? "")

                    Spacer()

                    Circle()
                        .fill(simulator.state == "Booted" ? Color.green : Color.red)
                        .frame(width: 10)
                }
                .padding(.vertical, 10)
            }
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .buttonStyle(.borderedProminent)
        .tint(
            manager.selectedSimulator?.id == simulator.id ? mainColor : systemBackground
        )
    }
}
