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
                        .inCase(manager.selectedSimulator?.id == simulator.id) {
                            Text(simulator.name ?? "")
                                .foregroundStyle(
                                    ColorPalette.background(colorScheme).color
                                )
                        }

                    Spacer()

                    Circle()
                        .fill(simulator.state == "Booted" ? Color.green : Color.red)
                        .frame(width: 10)
                        .padding(.trailing, 10)
                }
                .padding(.vertical, 10)
                .background(
                    manager.selectedSimulator?.id == simulator.id ? ColorPalette.foreground(colorScheme).color : ColorPalette.background(colorScheme).color
                )
            }
        )
    }
}
