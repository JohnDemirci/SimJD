//
//  CreateSimulatorView.swift
//  SimJD
//
//  Created by John Demirci on 3/31/25.
//

import SwiftUI

struct CreateSimulatorView: View {
    @State private var viewModel = CreateSimulatorViewModel()
    private let deviceTypes: [String]
    private let runtimes: [String]
    private let manager: SimulatorManager

    init(
        deviceTypes: [String],
        runtimes: [String],
        manager: SimulatorManager = .live
    ) {
        self.deviceTypes = deviceTypes
        self.runtimes = runtimes
        self.manager = manager
    }

    var body: some View {
        PanelView(title: "Create Simulator", columnWidth: 400) {
            VStack {
                Picker("Device Type", selection: $viewModel.selectedDeviceType) {
                    ForEach(deviceTypes, id: \.self) { deviceType in
                        Text(deviceType)
                    }
                }
                Picker("Runtime", selection: $viewModel.selectedRuntime) {
                    ForEach(runtimes, id: \.self) { runtime in
                        Text(runtime)
                    }
                }
                TextField("Title", text: $viewModel.name)

                Button("Create") {
                    viewModel.handleDidSelectCreate(manager)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .task {
                await KeyboardEvent.shared.removeObservation()
            }
        }
        .onDisappear {
            Task {
                await KeyboardEvent.shared.watchEvent()
            }
        }
    }
}

@MainActor
@Observable
final class CreateSimulatorViewModel {
    fileprivate var name: String = ""
    fileprivate var selectedDeviceType: String = ""
    fileprivate var selectedRuntime: String = ""

    func handleDidSelectCreate(_ manager: SimulatorManager) {
        let deviceIdentifier = trimIdentifier(selectedDeviceType)
        let runtimeIdentifier = trimIdentifier(selectedRuntime)

        guard
            !deviceIdentifier.isEmpty,
            !runtimeIdentifier.isEmpty,
            !name.isEmpty
        else {
            return
        }

        switch manager.createSimulator(name: name, deviceIdentifier: deviceIdentifier, runtimeIdentifier: runtimeIdentifier) {
        case .success:
            dump("successfully created simulator")
        case .failure(let failure):
            dump("failied to create simulator: \(failure.localizedDescription)")
        }
    }

    private func trimIdentifier(_ string: String) -> String {
        let slices = string.split(separator: " ")
        let lastSlice = "\(slices.last ?? "")"
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        return lastSlice
    }
}
