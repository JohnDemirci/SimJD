//
//  SimulatorInformationView.swift
//  SimJD
//
//  Created by John Demirci on 12/1/24.
//

import SwiftUI
import AppKit

struct SimulatorInformationView: View {
    @Bindable private var simManager: SimulatorManager

    init(simManager: SimulatorManager) {
        self.simManager = simManager
    }

    var body: some View {
        OptionalView(simManager.selectedSimulator) { simulator in
            simulatorNameView(simulator)
            simulatorIDView(simulator)
            simulatorDeviceTypeView(simulator)
            simulatorOSVersionView(simulator)
        }
    }
}

private extension SimulatorInformationView {
    func simulatorNameView(_ simulator: Simulator) -> some View {
        Text(simulator.name ?? "")
            .font(.largeTitle)
    }

    func simulatorIDView(_ simulator: Simulator) -> some View {
        VStack {
            Text("Unique Identifier")
                .font(.title)
                .bold()
            Text(simulator.id)
        }
        .padding()
        .frame(minWidth: 500)
        .foregroundStyle(Color.gray)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 2)
                .fill(Color.gray)
                .background(Color.black.opacity(0.3))
        }
        .overlay(alignment: .trailing) {
            Button("Copy") {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(simulator.id, forType: .string)
            }
            .padding()
        }
    }

    func simulatorDeviceTypeView(_ simulator: Simulator) -> some View {
        VStack {
            Text("Device Type")
                .font(.title)
            Text(simulator.deviceTypeIdentifier ?? "")
        }
        .padding()
        .frame(minWidth: 500)
        .foregroundStyle(Color.gray)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 2)
                .fill(Color.gray)
                .background(Color.orange.opacity(0.3))
        }
    }

    func simulatorOSVersionView(_ simulator: Simulator) -> some View {
        VStack {
            Text("OS Version")
                .font(.title)
            Text(simulator.os?.name ?? "")
        }
        .padding()
        .frame(minWidth: 500)
        .foregroundStyle(Color.gray)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 2)
                .fill(Color.gray)
                .background(Color.yellow.opacity(0.3))
        }
    }
}
