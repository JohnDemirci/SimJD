//
//  SimulatorManager.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Combine
import Foundation
import OrderedCollections
import SwiftUI

@Observable
final class SimulatorManager {
    @ObservationIgnored
    private var cancellables: [AnyCancellable] = []

    let simulatorClient: SimulatorClient
    var simulators: OrderedDictionary<OS.Name, [Simulator]> = [:]

    var selectedSimulator: Simulator? = nil {
        didSet {
            if let selectedSimulator {
                self.fetchLocale(simulator: selectedSimulator)
            }
        }
    }

    var processes: [Simulator.ID: [ProcessInfo]] = [:]
    var installedApplications: [Simulator.ID: [InstalledAppDetail]] = [:]
    var locales: [Simulator.ID: String] = [:]

    init(
        simulatorClient: SimulatorClient = .live
    ) {
        self.simulatorClient = simulatorClient
        self.registerObserver()
        self.fetchSimulators()
    }
}

extension SimulatorManager {
    func didSelectSimulator(_ simulator: Simulator) {
        self.selectedSimulator = simulator
    }

    @discardableResult
    func fetchSimulators() -> Result<Void, Failure> {
        switch simulatorClient.fetchSimulatorDictionary() {
        case .success(let dict):
            self.simulators = dict

            handleSimulatorSelection()

            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func openSimulator(_ simulator: Simulator) -> Result<Void, Failure> {
        switch simulatorClient.openSimulator(simulator: simulator.id) {
        case .success:
            didOpenSimulator(simulator)
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    private func handleSimulatorSelection() {
        guard let selectedSimulator else {
			self.selectedSimulator = simulators.flatMap(\.value).first
            return
        }

        guard let selectedSimulatorOS = selectedSimulator.os else { return }

        guard let updatedSelectedSimulator = self.simulators[selectedSimulatorOS]?.first(where: {
            $0.id == selectedSimulator.id
        }) else {
            return
        }

        self.selectedSimulator = updatedSelectedSimulator
    }

    private func didOpenSimulator(_ simulator: Simulator) {
        guard let os = simulator.os else { return }
        let index = simulators[os]?.firstIndex {
            $0.id == simulator.id
        }

        if let index {
            simulators[os]?[index].state = "Booted"
            selectedSimulator = simulators[os]?[index]
        }
    }

    @discardableResult
    func deleteSimulator(_ simulator: Simulator) -> Result<Void, Failure> {
        switch simulatorClient.deleteSimulator(simulator: simulator.id) {
        case .success:
            handleDeleteSimulator(simulator)
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    func handleDeleteSimulator(_ simulator: Simulator) {
        guard let os = simulator.os else { return }

        let index = simulators[os]?.firstIndex {
            $0.id == simulator.id
        }

        if let index {
            simulators[os]?.remove(at: index)
            selectedSimulator = nil
            handleSimulatorSelection()
        }
    }

    @discardableResult
    func shutdownSimulator(_ simulator: Simulator) -> Result<Void, Failure> {
        switch simulatorClient.shutdownSimulator(simulator: simulator.id) {
        case .success:
            guard let os = simulator.os else { return  .success(()) }

            let index = simulators[os]?.firstIndex {
                $0.id == simulator.id
            }

            if let index {
                simulators[os]?[index].state = "Shutdown"
                selectedSimulator = simulators[os]?[index]
            }

            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func fetchRunningProcesses(for simulator: Simulator) -> Result<[ProcessInfo], Failure> {
        switch simulatorClient.activeProcesses(simulator: simulator.id) {
        case .success(let processInfo):
            self.processes[simulator.id] = processInfo
            return .success(processInfo)
        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func fetchInstalledApplications(
        for simulator: Simulator
    ) -> Result<[InstalledAppDetail], Failure> {
        switch simulatorClient.installedApps(simulator: simulator.id) {
        case .success(let installedApps):
            self.installedApplications[simulator.id] = installedApps
            return .success(installedApps)
        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func eraseContents(in simulator: Simulator) -> Result<Void, Failure> {
        simulatorClient.eraseContents(simulator: simulator.id)
    }

    @discardableResult
    func updateLocation(
        in simulator: Simulator,
        latitude: Double,
        longtitude: Double
    ) -> Result<Void, Failure> {
        simulatorClient.updateLocation(
            simulator: simulator.id,
            latitude: latitude,
            longitude: longtitude
        )
    }

    private func fetchLocale(simulator: Simulator)  {
        switch simulatorClient.fetchLocale(simulator.id) {
        case .success(let locale):
            if !locale.isEmpty {
                self.locales[simulator.id] = locale
            }

        case .failure:
            break
        }
    }
}

extension SimulatorManager {
    func registerObserver() {
        NotificationCenter
            .default
            .publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [unowned self] _ in
                _ = self.fetchSimulators()
            }
            .store(in: &cancellables)
    }
}
