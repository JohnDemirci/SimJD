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

@MainActor
@Observable
final class SimulatorManager {
    @ObservationIgnored
    nonisolated(unsafe)
    private var cancellables: [AnyCancellable] = []

    nonisolated
    private let simulatorClient: SimulatorClient

    @ObservationIgnored
    private var backgroundRefreshTask: Task<Void, Never>?

    var simulators: OrderedDictionary<OS.Name, [Simulator]> = [:]

    private(set) var selectedSimulator: Simulator? = nil {
        didSet {
            if selectedSimulator != nil {
                didChangeSelectedSimulator()
            }
        }
    }

    var processes: [Simulator.ID: [ProcessInfo]] = [:]
    var installedApplications: [Simulator.ID: [InstalledAppDetail]] = [:]
    var locales: [Simulator.ID: String] = [:]
    var availableDeviceTypes: [String]? = nil
    var availableRuntimes: [String]? = nil

    private init(
        simulatorClient: SimulatorClient = .live
    ) {
        self.simulatorClient = simulatorClient
        self.registerObserver()
        self.fetchSimulators()
    }

    deinit {
        backgroundRefreshTask?.cancel()
        backgroundRefreshTask = nil
    }

#if DEBUG
    init(client: SimulatorClient = .testing) {
        self.simulatorClient = client
    }
#endif
    static let live = SimulatorManager(simulatorClient: .live)
}

extension SimulatorManager {
    func didSelectSimulator(_ simulator: Simulator) {
        guard let _ = getSimulatorIfExists(simulator) else { return }
        self.selectedSimulator = simulator
    }

    @discardableResult
    func createSimulator(
        name: String,
        deviceIdentifier: String,
        runtimeIdentifier: String
    ) -> Result<Void, Failure> {
        switch simulatorClient.createSimulator(
            name: name,
            deviceIdentifier: deviceIdentifier,
            runtimeIdentifier: runtimeIdentifier
        ) {
        case .success:
            let _ = fetchSimulators()
            return .success(())
        case .failure(let failure):
            return .failure(failure)
        }
    }

    @discardableResult
    func fetchAvailableDeviceTypes() -> Result<[String], Failure> {
        switch simulatorClient.getDeviceList() {
        case .success(let devices):
            self.availableDeviceTypes = devices
            return .success(devices)
        case .failure(let failure):
            return .failure(failure)
        }
    }

    @discardableResult
    func fetchRuntimes() -> Result<[String], Failure> {
        switch simulatorClient.getRuntimes() {
        case .success(let runtimes):
            self.availableRuntimes = runtimes
            return .success(runtimes)

        case .failure(let failure):
            return .failure(failure)
        }
    }

    @discardableResult
    func fetchSimulators() -> Result<Void, Failure> {
        switch simulatorClient.fetchSimulatorDictionary() {
        case .success(let dict):
            self.simulators = dict

            handleSimulatorSelection()

            return .success(())

        case .failure(let error):
            self.simulators = [:]
            self.selectedSimulator = nil
            self.processes = [:]
            self.installedApplications = [:]
            self.locales = [:]
            return .failure(error)
        }
    }

    @discardableResult
    func openSimulator(_ simulator: Simulator) -> Result<Void, Failure> {
        guard let _ = getSimulatorIfExists(simulator) else {
            return .failure(Failure.message("Simulator Does not Exist"))
        }

        switch simulatorClient.openSimulator(simulator: simulator.id) {
        case .success:
            didOpenSimulator(simulator)
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    private func handleSimulatorSelection() {
        guard
            let selectedSimulator,
            let existingSimulator = getSimulatorIfExists(selectedSimulator)
        else {
            self.selectedSimulator = simulators.flatMap(\.value).first
            return
        }

        self.selectedSimulator = existingSimulator
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
        guard let _ = getSimulatorIfExists(simulator) else {
            return .failure(Failure.message("Simulator Does not Exist"))
        }

        switch simulatorClient.deleteSimulator(simulator: simulator.id) {
        case .success:
            handleDeleteSimulator(simulator)
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    private func handleDeleteSimulator(_ simulator: Simulator) {
        guard let os = simulator.os else { return }

        let index = simulators[os]?.firstIndex {
            $0.id == simulator.id
        }

        if let index {
            simulators[os]?.remove(at: index)
            selectedSimulator = nil
            locales[simulator.id] = nil
            processes[simulator.id] = nil
            installedApplications[simulator.id] = nil
            handleSimulatorSelection()
        }
    }

    @discardableResult
    func shutdownSimulator(_ simulator: Simulator) -> Result<Void, Failure> {
        guard let _ = getSimulatorIfExists(simulator) else {
            return .failure(Failure.message("Simulator Does not Exist"))
        }

        guard let os = simulator.os else {
            // if getSimulatorIfExists goes through, then it should be inpossible to reach here
            return .failure(Failure.message("Simulator has no OS"))
        }

        switch simulatorClient.shutdownSimulator(simulator: simulator.id) {
        case .success:
            let index = simulators[os]?.firstIndex {
                $0.id == simulator.id
            }

            if let index {
                simulators[os]?[index].state = "Shutdown"
                selectedSimulator = simulators[os]?[index]
                processes[simulator.id] = nil
                installedApplications[simulator.id] = nil
                locales[simulator.id] = nil
            }

            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func fetchRunningProcesses(for simulator: Simulator) -> Result<[ProcessInfo], Failure> {
        guard let _ = getSimulatorIfExists(simulator) else {
            return .failure(Failure.message("Simulator Does not Exist"))
        }

        switch simulatorClient.activeProcesses(simulator: simulator.id) {
        case .success(let processInfo):
            return .success(processInfo)

        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func fetchInstalledApplications(
        for simulator: Simulator
    ) -> Result<[InstalledAppDetail], Failure> {
        guard let _ = getSimulatorIfExists(simulator) else {
            return .failure(Failure.message("Simulator Does not Exist"))
        }

        switch simulatorClient.installedApps(simulator: simulator.id) {
        case .success(let installedApps):
            return .success(installedApps)
        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func eraseContents(in simulator: Simulator) -> Result<Void, Failure> {
        guard let _ = getSimulatorIfExists(simulator) else {
            return .failure(Failure.message("Simulator Does not Exist"))
        }

        let result = simulatorClient.eraseContents(simulator: simulator.id)

        if case .success = result {
            didChangeSelectedSimulator()
        }

        return result
    }

    @discardableResult
    func updateLocation(
        in simulator: Simulator,
        latitude: Double,
        longtitude: Double
    ) -> Result<Void, Failure> {
        guard let _ = getSimulatorIfExists(simulator) else {
            return .failure(Failure.message("Simulator Does not Exist"))
        }

        return simulatorClient.updateLocation(
            simulator: simulator.id,
            latitude: latitude,
            longitude: longtitude
        )
    }

    private func fetchLocale(simulator: Simulator) -> Result<String, Failure>  {
        guard let _ = getSimulatorIfExists(simulator) else {
            return .failure(Failure.message("Simulator does not exists"))
        }

        return simulatorClient.fetchLocale(simulator.id)
    }

    func uninstall(
        _ app: InstalledAppDetail,
        simulator: Simulator
    ) -> Result<Void, Failure> {
        guard let _ = getSimulatorIfExists(simulator) else {
            return .failure(Failure.message("Simulator does not exist. Please check your selection and try again."))
        }

        let result = simulatorClient.uninstallApp(
            app: app,
            at: simulator.id
        )

        if case .success = result {
            self.installedApplications[simulator.id]?.removeAll(where: {
                $0 == app
            })
        }

        return result
    }
}

private extension SimulatorManager {
    func getSimulatorIfExists(_ simulator: Simulator) -> Simulator? {
        guard
            let os = simulator.os,
            let simulators = simulators[os],
            let sim = simulators.first(where: { $0.id == simulator.id })
        else { return nil }

        return sim
    }
}

extension SimulatorManager {
    func registerObserver() {
        NotificationCenter
            .default
            .publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [unowned self] _ in
                backgroundRefreshTask?.cancel()
                backgroundRefreshTask = nil
            }
            .store(in: &cancellables)


        NotificationCenter
            .default
            .publisher(for: NSApplication.didResignActiveNotification)
            .sink { [unowned self] _ in
                backgroundRefreshTask?.cancel()

                backgroundRefreshTask = Task { [weak self] in
                    try? await Task.sleep(for: .seconds(5))

                    guard let self = self, !Task.isCancelled else { return }

                    self.fetchSimulators()
                }
            }
            .store(in: &cancellables)
    }

    func didChangeSelectedSimulator() {
        guard let selectedSimulator else { return }

        if selectedSimulator.state == "Booted" {
            let fetchInstalledApplicationsResult = fetchInstalledApplications(for: selectedSimulator)
            let fetchLocaleResult = fetchLocale(simulator: selectedSimulator)
            let fetchProcessesResult = fetchRunningProcesses(for: selectedSimulator)

            installedApplications.handleResult(fetchInstalledApplicationsResult, for: selectedSimulator.id)
            processes.handleResult(fetchProcessesResult, for: selectedSimulator.id)
            locales.handleResult(fetchLocaleResult, for: selectedSimulator.id)
        } else if selectedSimulator.state == "Shutdown" {
            if self.processes[selectedSimulator.id] != nil {
                self.processes[selectedSimulator.id] = nil
            }

            if self.installedApplications[selectedSimulator.id] != nil {
                self.installedApplications[selectedSimulator.id] = nil
            }

            if self.locales[selectedSimulator.id] != nil {
                self.locales[selectedSimulator.id] = nil
            }
        }
    }
}
