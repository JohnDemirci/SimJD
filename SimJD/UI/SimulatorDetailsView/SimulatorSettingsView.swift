//
//  SimulatorSettingsView.swift
//  SimJD
//
//  Created by John Demirci on 1/13/25.
//

import SwiftUI

struct SimulatorSettingsView: View {
    enum Event {
        case didSelectBatterySettings(Simulator)
        case didSelectEraseContentAndSettings(Simulator)
        case didSelectDeleteSimulator(Simulator)
    }

    private let columnWidth: CGFloat
    private let selectedSimulator: Simulator
    private let sendEvent: (Event) -> Void

    init(
        columnWidth: CGFloat,
        selectedSimulator: Simulator,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.columnWidth = columnWidth
        self.selectedSimulator = selectedSimulator
        self.sendEvent = sendEvent
    }

    var body: some View {
        PanelView(
            title: "Settings",
            columnWidth: columnWidth,
            content: {
                VStack(alignment: .leading) {
                    Button("Erase Content and Settings") {
                        sendEvent(.didSelectEraseContentAndSettings(selectedSimulator))
                    }

                    Button("Delete Simulator") {
                        sendEvent(.didSelectDeleteSimulator(selectedSimulator))
                    }

                    Button("Battery Settings") {
                        sendEvent(.didSelectBatterySettings(selectedSimulator))
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.clear)
                .padding()
            }
        )
    }
}
