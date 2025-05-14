//
//  BatterySettingsView.swift
//  SimJD
//
//  Created by John Demirci on 5/12/25.
//

import SwiftUI

struct BatterySettingsView: View {
    @State private var viewModel: BatterySettingsViewModel

    init(viewModel: BatterySettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        PanelView(
            title: "Battery Settings",
            columnWidth: 400,
            content: {
                panelViewContent
            }
        )
        .padding()
    }

    var panelViewContent: some View {
        VStack {
            IntSlider(value: $viewModel.level)
            Picker("state", selection: $viewModel.state) {
                ForEach(BatteryState.allCases) { (state: BatteryState) in
                    Text(state.id)
                        .tag(state)
                }
            }
            Button("Done") {
                viewModel.didSelectDone()
            }
        }
        .padding()
    }
}

struct IntSlider: View {
    @Binding var value: Int
    @State private var currentValue: Double = 100

    var body: some View {
        Slider(
            value: $currentValue,
            in: ClosedRange(uncheckedBounds: (1, 100)),
            label: {
                Text(value, format: .number)
            }
        )
        .onChange(of: currentValue) {
            self.value = Int(currentValue)
        }
    }
}
