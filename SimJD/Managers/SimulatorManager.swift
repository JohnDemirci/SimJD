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
    var selectedSimulator: Simulator? = nil

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

            if selectedSimulator == nil {
                handleSelectedSimulator()
            }

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

    private func handleSelectedSimulator() {
        self.selectedSimulator = simulators.values.first?.first
    }

    func didOpenSimulator(_ simulator: Simulator) {
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

            if selectedSimulator?.id == simulator.id {
                handleSelectedSimulator()
            }
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
        simulatorClient.activeProcesses(simulator: simulator.id)
    }

    @discardableResult
    func fetchInstalledApplications(for simulator: Simulator) -> Result<[InstalledAppDetail], Failure> {
        simulatorClient.installedApps(simulator: simulator.id)
    }

    @discardableResult
    func eraseContents(in simulator: Simulator) -> Result<Void, Failure> {
        simulatorClient.eraseContents(simulator: simulator.id)
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
