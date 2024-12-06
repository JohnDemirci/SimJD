//
//  SimulatorClient.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation
import OrderedCollections

struct SimulatorClient {
    fileprivate var _shutdownSimulator: (String) -> Result<Void, Failure>
    fileprivate var _openSimulator: (String) -> Result<Void, Failure>
    fileprivate var _activeProcesses: (String) -> Result<[ProcessInfo], Failure>
    fileprivate var _eraseContentAndSettings: (String) -> Result<Void, Failure>
    fileprivate var _installedApps: (String) -> Result<[InstalledAppDetail], Failure>
    fileprivate var _uninstallApp: (String, String) -> Result<Void, Failure>
    fileprivate var _deleteSimulator: (String) -> Result<Void, Failure>
    fileprivate var _fetchSimulatorDictionary: () -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure>

    private init(
        _shutdownSimulator: @escaping (String) -> Result<Void, Failure>,
        _openSimulator: @escaping (String) -> Result<Void, Failure>,
        _activeProcesses: @escaping (String) -> Result<[ProcessInfo], Failure>,
        _eraseContentAndSettings: @escaping (String) -> Result<Void, Failure>,
        _installedApps: @escaping (String) -> Result<[InstalledAppDetail], Failure>,
        _uninstallApp: @escaping (String, String) -> Result<Void, Failure>,
        _deleteSimulator: @escaping (String) -> Result<Void, Failure>,
        _fetchSimulatorDictionary: @escaping () -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure>
    ) {
        self._shutdownSimulator = _shutdownSimulator
        self._openSimulator = _openSimulator
        self._activeProcesses = _activeProcesses
        self._eraseContentAndSettings = _eraseContentAndSettings
        self._installedApps = _installedApps
        self._uninstallApp = _uninstallApp
        self._deleteSimulator = _deleteSimulator
        self._fetchSimulatorDictionary = _fetchSimulatorDictionary
    }

    func shutdownSimulator(simulator: String) -> Result<Void, Failure> {
        return _shutdownSimulator(simulator)
    }

    func openSimulator(simulator: String) -> Result<Void, Failure> {
        return _openSimulator(simulator)
    }

    func activeProcesses(simulator: String) -> Result<[ProcessInfo], Failure> {
        return _activeProcesses(simulator)
    }

    func eraseContents(simulator: String) -> Result<Void, Failure> {
        return _eraseContentAndSettings(simulator)
    }

    func installedApps(simulator: String) -> Result<[InstalledAppDetail], Failure> {
        return _installedApps(simulator)
    }

    func uninstallApp(_ bundleID: String, at simulatorID: String) -> Result<Void, Failure> {
        return _uninstallApp(bundleID, simulatorID)
    }

    func deleteSimulator(simulator: String) -> Result<Void, Failure> {
        return _deleteSimulator(simulator)
    }

    func fetchSimulatorDictionary() -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure> {
        return _fetchSimulatorDictionary()
    }
}

extension SimulatorClient {
    nonisolated(unsafe)
    static let live: SimulatorClient = .init(
        _shutdownSimulator: {
            handleShutdownSimulator(id: $0)
        },
        _openSimulator: {
            handleOpenSimulator($0)
        },
        _activeProcesses: {
            handleRunningProcesses($0)
        },
        _eraseContentAndSettings: {
            handleEraseContentAndSettings($0)
        },
        _installedApps: {
            handleInstalledApplications($0)
        },
        _uninstallApp: {
            handleUninstallApplication($0, simulatorID: $1)
        },
        _deleteSimulator: {
            handleDeleteSimulator($0)
        },
        _fetchSimulatorDictionary: {
            handleFetchSimulators()
        }
    )

    #if DEBUG
    nonisolated(unsafe)
    static var testing: SimulatorClient = .init(
        _shutdownSimulator: { _ in fatalError("not implemented") },
        _openSimulator: { _ in fatalError("not implemented") },
        _activeProcesses: { _ in fatalError("not implemented") },
        _eraseContentAndSettings: { _ in fatalError("not implemented") },
        _installedApps: { _ in fatalError("not implemented") },
        _uninstallApp: { _, _ in fatalError("not implemented") },
        _deleteSimulator: { _ in fatalError("not implemented") },
        _fetchSimulatorDictionary: { fatalError("not implemented") }
    )
    #endif
}

extension SimulatorClient {
    @discardableResult
    mutating func mutate(
        _shutdownSimulator:  ((String) -> Result<Void, Failure>)? = nil,
        _openSimulator:  ((String) -> Result<Void, Failure>)? = nil,
        _activeProcesses:  ((String) -> Result<[ProcessInfo], Failure>)? = nil,
        _eraseContentAndSettings:  ((String) -> Result<Void, Failure>)? = nil,
        _installedApps:  ((String) -> Result<[InstalledAppDetail], Failure>)? = nil,
        _uninstallApp:  ((String, String) -> Result<Void, Failure>)? = nil,
        _deleteSimulator: ((String) -> Result<Void, Failure>)? = nil,
        _fetchSimulatorDictionary: (() -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure>)? = nil
    ) -> Self {
        if let _shutdownSimulator = _shutdownSimulator {
            self._shutdownSimulator = _shutdownSimulator
        }

        if let _openSimulator = _openSimulator {
            self._openSimulator = _openSimulator
        }

        if let _activeProcesses = _activeProcesses {
            self._activeProcesses = _activeProcesses
        }

        if let _eraseContentAndSettings = _eraseContentAndSettings {
            self._eraseContentAndSettings = _eraseContentAndSettings
        }

        if let _installedApps = _installedApps {
            self._installedApps = _installedApps
        }

        if let _uninstallApp = _uninstallApp {
            self._uninstallApp = _uninstallApp
        }

        if let _deleteSimulator = _deleteSimulator {
            self._deleteSimulator = _deleteSimulator
        }

        if let _fetchSimulatorDictionary = _fetchSimulatorDictionary {
            self._fetchSimulatorDictionary = _fetchSimulatorDictionary
        }

        return self
    }
}
