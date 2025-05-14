//
//  SimulatorClient.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation
import OrderedCollections

struct SimulatorClient: @unchecked Sendable {
    fileprivate var _activeProcesses: (String) -> Result<[ProcessInfo], Failure>
    fileprivate var _createSimulator: (String, String, String) -> Result<Void, Failure>
    fileprivate var _deleteSimulator: (String) -> Result<Void, Failure>
    fileprivate var _eraseContentAndSettings: (String) -> Result<Void, Failure>
    fileprivate var _fetchLocale: (String) -> Result<String, Failure>
    fileprivate var _fetchSimulatorDictionary: () -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure>
    fileprivate var _getDeviceList: () -> Result<[String], Failure>
    fileprivate var _getRuntimes: () -> Result<[String], Failure>
    fileprivate var _installedApps: (String) -> Result<[InstalledAppDetail], Failure>
    fileprivate var _openSimulator: (String) -> Result<Void, Failure>
    fileprivate var _retrieveBatteryState: (String) -> Result<(BatteryState, Int), Failure>
    fileprivate var _shutdownSimulator: (String) -> Result<Void, Failure>
    fileprivate var _uninstallApp: (InstalledAppDetail, String) -> Result<Void, Failure>
    fileprivate var _updateBatteryState: (String, BatteryState, Int) -> Result<Void, Failure>
    fileprivate var _updateLocation: (String, Double, Double) -> Result<Void, Failure>

    private init(
        _activeProcesses: @escaping (String) -> Result<[ProcessInfo], Failure>,
        _createSimulator: @escaping (String, String, String) -> Result<Void, Failure>,
        _deleteSimulator: @escaping (String) -> Result<Void, Failure>,
        _eraseContentAndSettings: @escaping (String) -> Result<Void, Failure>,
        _fetchLocale: @escaping (String) -> Result<String, Failure>,
        _fetchSimulatorDictionary: @escaping () -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure>,
        _getDeviceList: @escaping () -> Result<[String], Failure>,
        _getRuntimes: @escaping () -> Result<[String], Failure>,
        _installedApps: @escaping (String) -> Result<[InstalledAppDetail], Failure>,
        _openSimulator: @escaping (String) -> Result<Void, Failure>,
        _retrieveBatteryState: @escaping (String) -> Result<(BatteryState, Int), Failure>,
        _shutdownSimulator: @escaping (String) -> Result<Void, Failure>,
        _uninstallApp: @escaping (InstalledAppDetail, String) -> Result<Void, Failure>,
        _updateBatteryState: @escaping (String, BatteryState, Int) -> Result<Void, Failure>,
        _updateLocation: @escaping (String, Double, Double) -> Result<Void, Failure>
    ) {
        self._activeProcesses = _activeProcesses
        self._createSimulator = _createSimulator
        self._deleteSimulator = _deleteSimulator
        self._eraseContentAndSettings = _eraseContentAndSettings
        self._fetchLocale = _fetchLocale
        self._fetchSimulatorDictionary = _fetchSimulatorDictionary
        self._getDeviceList = _getDeviceList
        self._getRuntimes = _getRuntimes
        self._installedApps = _installedApps
        self._openSimulator = _openSimulator
        self._retrieveBatteryState = _retrieveBatteryState
        self._shutdownSimulator = _shutdownSimulator
        self._uninstallApp = _uninstallApp
        self._updateBatteryState = _updateBatteryState
        self._updateLocation = _updateLocation
    }

    func activeProcesses(simulator: String) -> Result<[ProcessInfo], Failure> {
        return _activeProcesses(simulator)
    }

    func createSimulator(name: String, deviceIdentifier: String, runtimeIdentifier: String) -> Result<Void, Failure> {
        return _createSimulator(name, deviceIdentifier, runtimeIdentifier)
    }

    func deleteSimulator(simulator: String) -> Result<Void, Failure> {
        return _deleteSimulator(simulator)
    }

    func eraseContents(simulator: String) -> Result<Void, Failure> {
        return _eraseContentAndSettings(simulator)
    }

    func fetchLocale(_ id: String) -> Result<String, Failure> {
        return _fetchLocale(id)
    }

    func fetchSimulatorDictionary() -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure> {
        return _fetchSimulatorDictionary()
    }

    func getDeviceList() -> Result<[String], Failure> {
        return _getDeviceList()
    }

    func getRuntimes() -> Result<[String], Failure> {
        return _getRuntimes()
    }

    func installedApps(simulator: String) -> Result<[InstalledAppDetail], Failure> {
        return _installedApps(simulator)
    }

    func openSimulator(simulator: String) -> Result<Void, Failure> {
        return _openSimulator(simulator)
    }

    func retrieveStatusBarState(
        id: String
    ) -> Result<(BatteryState, Int), Failure> {
        return _retrieveBatteryState(id)
    }

    func shutdownSimulator(simulator: String) -> Result<Void, Failure> {
        return _shutdownSimulator(simulator)
    }

    func uninstallApp(app: InstalledAppDetail, at simulatorID: String) -> Result<Void, Failure> {
        return _uninstallApp(app, simulatorID)
    }

    func updateBatteryState(
        id: String,
        state: BatteryState,
        level: Int
    ) -> Result<Void, Failure> {
        return _updateBatteryState(id, state, level)
    }

    func updateLocation(simulator: String, latitude: Double, longitude: Double) -> Result<Void, Failure> {
        return _updateLocation(simulator, latitude, longitude)
    }
}

extension SimulatorClient {
    static let live: SimulatorClient = .init(
        _activeProcesses: { (id: String) in
            handleRunningProcesses(id)
        },
        _createSimulator: { (name: String, deviceIdentifier: String, runtimeIdentifier: String) in
            handleCreateSimulator(name: name, deviceIdentifier: deviceIdentifier, runtimeIdentifier: runtimeIdentifier)
        },
        _deleteSimulator: { (id: String) in
            handleDeleteSimulator(id)
        },
        _eraseContentAndSettings: { (id: String) in
            handleEraseContentAndSettings(id)
        },
        _fetchLocale: { (id: String) in
            handleFetchLocale(id)
        },
        _fetchSimulatorDictionary: {
            handleFetchSimulators()
        },
        _getDeviceList: {
            handleGetDeviceList()
        },
        _getRuntimes: {
            handleGetRuntimes()
        },
        _installedApps: { (id: String) in
            handleInstalledApplications(id)
        },
        _openSimulator: { (id: String) in
            handleOpenSimulator(id)
        },
        _retrieveBatteryState: { (id: String) in
            handleRetrieveBatteryState(id: id)
        },
        _shutdownSimulator: { (id: String) in
            handleShutdownSimulator(id: id)
        },
        _uninstallApp: { (installedApp: InstalledAppDetail, id: String) in
            handleUninstallApplication(installedApp, simulatorID: id)
        },
        _updateBatteryState: { (id: String, state: BatteryState, level: Int) in
            handleUpdateBatteryState(id: id, state: state, level: level)
        },
        _updateLocation: { (simulatorID: String, latitude: Double, longtitude: Double) in
            handleUpdateLocation(
                simulatorID: simulatorID,
                latitude: latitude,
                longitude: longtitude
            )
        }
    )

    #if DEBUG
    // implementations will purposefully crash
    // the expected usecase for the testing variable is to use the mutate function to provide implementation
    nonisolated(unsafe)
    static var testing: SimulatorClient = .init(
        _activeProcesses: { _ in fatalError("not implemented") },
        _createSimulator: { _, _, _ in fatalError("not implemented") },
        _deleteSimulator: { _ in fatalError("not implemented") },
        _eraseContentAndSettings: { _ in fatalError("not implemented") },
        _fetchLocale: { _ in fatalError("not implemented") },
        _fetchSimulatorDictionary: { fatalError("not implemented") },
        _getDeviceList: { fatalError("not implemented") },
        _getRuntimes: { fatalError("not implemented") },
        _installedApps: { _ in fatalError("not implemented") },
        _openSimulator: { _ in fatalError("not implemented") },
        _retrieveBatteryState: { _ in fatalError("not implemented") },
        _shutdownSimulator: { _ in fatalError("not implemented") },
        _uninstallApp: { _, _ in fatalError("not implemented") },
        _updateBatteryState: { _, _, _ in fatalError("not implemented") },
        _updateLocation: { _, _, _ in fatalError("not implemented") }
    )
    #endif
}

#if DEBUG
extension SimulatorClient {
    @discardableResult
    mutating func mutate(
        _activeProcesses: ((String) -> Result<[ProcessInfo], Failure>)? = nil,
        _createSimulator: ((String, String, String) -> Result<Void, Failure>)? = nil,
        _deleteSimulator: ((String) -> Result<Void, Failure>)? = nil,
        _eraseContentAndSettings: ((String) -> Result<Void, Failure>)? = nil,
        _fetchLocale: ((String) -> Result<String, Failure>)? = nil,
        _fetchSimulatorDictionary: (() -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure>)? = nil,
        _getDeviceList: (() -> Result<[String], Failure>)? = nil,
        _getRuntimes: (() -> Result<[String], Failure>)? = nil,
        _installedApps: ((String) -> Result<[InstalledAppDetail], Failure>)? = nil,
        _openSimulator: ((String) -> Result<Void, Failure>)? = nil,
        _retrieveBatteryState: ((String) -> Result<(BatteryState, Int), Failure>)? = nil,
        _shutdownSimulator: ((String) -> Result<Void, Failure>)? = nil,
        _uninstallApp: ((InstalledAppDetail, String) -> Result<Void, Failure>)? = nil,
        _updateBatteryState: ((String, BatteryState, Int) -> Result<Void, Failure>)? = nil,
        _updateLocation: ((String, Double, Double) -> Result<Void, Failure>)? = nil
    ) -> Self {
        if let _activeProcesses = _activeProcesses {
            self._activeProcesses = _activeProcesses
        }

        if let _createSimulator = _createSimulator {
            self._createSimulator = _createSimulator
        }

        if let _deleteSimulator = _deleteSimulator {
            self._deleteSimulator = _deleteSimulator
        }

        if let _eraseContentAndSettings = _eraseContentAndSettings {
            self._eraseContentAndSettings = _eraseContentAndSettings
        }

        if let _fetchLocale = _fetchLocale {
            self._fetchLocale = _fetchLocale
        }

        if let _fetchSimulatorDictionary = _fetchSimulatorDictionary {
            self._fetchSimulatorDictionary = _fetchSimulatorDictionary
        }

        if let _getDeviceList = _getDeviceList {
            self._getDeviceList = _getDeviceList
        }

        if let _getRuntimes = _getRuntimes {
            self._getRuntimes = _getRuntimes
        }

        if let _installedApps = _installedApps {
            self._installedApps = _installedApps
        }

        if let _openSimulator = _openSimulator {
            self._openSimulator = _openSimulator
        }

        if let _retrieveBatteryState = _retrieveBatteryState {
            self._retrieveBatteryState = _retrieveBatteryState
        }

        if let _shutdownSimulator = _shutdownSimulator {
            self._shutdownSimulator = _shutdownSimulator
        }

        if let _uninstallApp = _uninstallApp {
            self._uninstallApp = _uninstallApp
        }

        if let _updateBatteryState = _updateBatteryState {
            self._updateBatteryState = _updateBatteryState
        }

        if let _updateLocation = _updateLocation {
            self._updateLocation = _updateLocation
        }

        return self
    }
}
#endif
