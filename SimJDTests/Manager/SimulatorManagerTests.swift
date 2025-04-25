//
//  SimulatorManagerTests.swift
//  SimJD
//
//  Created by John Demirci on 4/22/25.
//

import XCTest
import OrderedCollections
@testable import SimJD

@MainActor
final class SimulatorManagerTests: XCTestCase {
    private var manager: SimulatorManager!

    override func setUp() {
        super.setUp()
        initializeManager()
    }

    override func tearDown() {
        super.tearDown()
        self.manager = nil
    }
}

// MARK: - Simulator Selection Tests

extension SimulatorManagerTests {
    func testDidSelectSimulatorWhenNoSimulatorExists() {
        manager.didSelectSimulator(.sample)

        XCTAssertNil(manager.selectedSimulator)
    }

    func testDidSelectSimulatorSuccess() {
        initializeManager(_fetchSimulatorDictionary: {
            return .success([.iOS("18"): [.sample, .sample2]])
        })

        initializeManager()
        manager.fetchSimulators()
        manager.didSelectSimulator(.sample2)
        XCTAssertEqual(manager.selectedSimulator, .sample2)
    }
}

// MARK: - Simulator Creation Tests

extension SimulatorManagerTests {
    func testCreateSimulatorSuccess() {
        initializeManager(
            _createSimulator: { _, _, _ in
                return .success(())
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample, .sample2]])
            }
        )

        XCTAssertTrue(manager.simulators.isEmpty)

        let result = manager.createSimulator(
            name: "Sample",
            deviceIdentifier: "Sample2",
            runtimeIdentifier: "Sample3"
        )

        switch result {
        case .success:
            XCTAssertEqual(manager.simulators, [.iOS("18"): [.sample, .sample2]])
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testCreateSimulatorFailure() {
        let failure = Failure.message("Error")
        initializeManager(
            _createSimulator: { _, _, _ in
                return .failure(failure)
            }
        )

        XCTAssertTrue(manager.simulators.isEmpty)

        let result = manager.createSimulator(
            name: "Sample",
            deviceIdentifier: "Sample2",
            runtimeIdentifier: "Sample3"
        )

        switch result {
        case .success:
            XCTFail("should not be successful")
        case .failure(let error):
            XCTAssertEqual(failure, error)
            XCTAssertTrue(manager.simulators.isEmpty)
        }
    }
}

// MARK: - Fetch available device types

extension SimulatorManagerTests {
    func testGetAvailableDeviceTypeSuccess() {
        initializeManager(_getDeviceList: {
            return .success(["1", "2", "3"])
        })

        switch manager.fetchAvailableDeviceTypes() {
        case .success(let deviceIDs):
            XCTAssertEqual(manager.availableDeviceTypes, deviceIDs)
            XCTAssertEqual(deviceIDs, ["1", "2", "3"])
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testGetAvailableDeviceTypeFailure() {
        let failure = Failure.message("Error")
        initializeManager(_getDeviceList: {
            return .failure(failure)
        })

        switch manager.fetchAvailableDeviceTypes() {
        case .success:
            XCTFail("should not be successful")
        case .failure(let error):
            XCTAssertEqual(error, failure)
            XCTAssertNil(manager.availableDeviceTypes)
        }
    }
}

// MARK: - Test fetching runtimes

extension SimulatorManagerTests {
    func testFetchRunTimesSuccess() {
        initializeManager(_getRuntimes: {
            return .success(["1", "2", "3"])
        })

        switch manager.fetchRuntimes() {
        case .success(let runtimes):
            XCTAssertEqual(runtimes, manager.availableRuntimes)
            XCTAssertEqual(manager.availableRuntimes, ["1", "2", "3"])
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testGetRuntimesFailure() {
        let failure = Failure.message("Error")
        initializeManager(_getRuntimes: {
            return .failure(failure)
        })

        switch manager.fetchRuntimes() {
        case .success:
            XCTFail("should not be successful")
        case .failure(let error):
            XCTAssertEqual(error, failure)
            XCTAssertNil(manager.availableRuntimes)
        }
    }
}

// MARK: - Test fetching simulators

extension SimulatorManagerTests {
    func testFetchShutdownSimulatorsFreshSuccess() {
        initializeManager(_fetchSimulatorDictionary: {
            return .success([.iOS("18"): [.sample, .sample2]])
        })

        XCTAssertNil(manager.selectedSimulator)
        XCTAssertTrue(manager.simulators.isEmpty)

        manager.fetchSimulators()

        XCTAssertEqual(manager.selectedSimulator, .sample)
        XCTAssertEqual(
            manager.simulators,
            [.iOS("18"): [.sample, .sample2]]
        )
    }

    func testFetchBootedSimulatorsFreshSuccess() {
        let failure = Failure.message("Error")
        initializeManager(
            _activeProcesses: {
                if $0 == Simulator.sample.id {
                    return .success([])
                } else if $0 == Simulator.booted.id {
                    return .success([.sample])
                }

                return .failure(failure)
            },
            _installedApps: {
                if $0 == Simulator.sample.id {
                    return .success([])
                } else if $0 == Simulator.booted.id {
                    return .success([.fake])
                }

                return .failure(failure)
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample, .booted]])
            },
            _fetchLocale: { _ in
                return .success("en-US")
            }
        )

        manager.fetchSimulators()

        XCTAssertNil(manager.processes[Simulator.booted.id])
        XCTAssertNil(manager.installedApplications[Simulator.booted.id])
        XCTAssertNil(manager.locales[Simulator.booted.id])

        manager.didSelectSimulator(.booted)

        XCTAssertEqual(manager.selectedSimulator, .booted)
        XCTAssertEqual(manager.processes[Simulator.booted.id], [.sample])
        XCTAssertEqual(manager.installedApplications[Simulator.booted.id], [.fake])
        XCTAssertEqual(manager.locales[Simulator.booted.id], "en-US")
    }

    func testDidSelectSimulatorToNonExistingSimulator() {
        initializeManager(_fetchSimulatorDictionary: {
            return .success([.iOS("18"): [.sample, .sample2]])
        })

        manager.fetchSimulators()
        XCTAssertEqual(manager.selectedSimulator, .sample)
        manager.didSelectSimulator(.booted)
        XCTAssertEqual(manager.selectedSimulator, .sample)
    }

    func testOpenSimulatorSuccess() {
        initializeManager(
            _openSimulator: { _ in
                return .success(())
            },
            _activeProcesses: { _ in
                return .success([])
            },
            _installedApps: { _ in
                return .success([])
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample, .sample2]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.openSimulator(.sample) {
        case .success:
            XCTAssertEqual(manager.selectedSimulator?.id, Simulator.sample.id)
            XCTAssertEqual(manager.selectedSimulator?.state, "Booted")
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testOpenSimulatorFailure() {
        let failure: Failure = .message("Error")

        initializeManager(
            _openSimulator: { _ in
                return .failure(failure)
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample]])
            }
        )

        manager.fetchSimulators()

        switch manager.openSimulator(.sample) {
        case .success:
            XCTFail("Should not reach here")
        case .failure:
            break
        }
    }

    func testOpenNonExistingSimulator() {
        switch manager.openSimulator(.sample) {
        case .success:
            XCTFail("Should not reach here")
        case .failure:
            break
        }
    }

    func testdeleteSimulatorSuccess() {
        initializeManager(
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _deleteSimulator: { _ in
                return .success(())
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.deleteSimulator(.sample) {
        case .success:
            XCTAssertNil(manager.selectedSimulator)
            XCTAssertTrue(manager.simulators[.iOS("18")]!.isEmpty)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testDeleteSimulatorSuccessWhenThereAreMoreSimulators() {
        initializeManager(
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _deleteSimulator: { _ in
                return .success(())
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample, .booted]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.deleteSimulator(.sample) {
        case .success:
            XCTAssertEqual(manager.selectedSimulator, .booted)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testDeleteSimulatorFailure() {
        let failure: Failure = .message("Failed")
        initializeManager(
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _deleteSimulator: { _ in
                return .failure(failure)
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.booted, .sample]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.deleteSimulator(.booted) {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertEqual(error, failure)
            XCTAssertEqual(manager.simulators[.iOS("18")], [.booted, .sample])
            XCTAssertEqual(manager.selectedSimulator, .booted)
            XCTAssertEqual(manager.processes[Simulator.booted.id], [.sample])
            XCTAssertEqual(manager.installedApplications[Simulator.booted.id], [.fake])
            XCTAssertEqual(manager.locales[Simulator.booted.id], "en_US")
        }
    }

    func testDeleteNonExistingSimulatorDoesNothing() {
        switch manager.deleteSimulator(.sample) {
        case .success:
            XCTFail("Expected failure")
        case .failure:
            break
        }
    }

    func testShutdownSimulatorSuccess() {
        initializeManager(
            _shutdownSimulator: { _ in
                return .success(())
            },
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _deleteSimulator: { _ in
                return .success(())
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.booted, .sample]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        XCTAssertEqual(manager.simulators.values.first?[0].state, "Booted")

        switch manager.shutdownSimulator(.booted) {
        case .success:
            let values = manager.simulators.values.first
            XCTAssertEqual(values?[0].id, Simulator.booted.id)
            XCTAssertEqual(values?[0].state, "Shutdown")
            XCTAssertNil(manager.processes[Simulator.booted.id])
            XCTAssertNil(manager.installedApplications[Simulator.booted.id])
            XCTAssertNil(manager.locales[Simulator.booted.id])

        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testShutdownSimulatoWithNoOS() {
        initializeManager(
            _shutdownSimulator: { _ in
                return .success(())
            },
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _deleteSimulator: { _ in
                return .success(())
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.simWithNoOS, .sample]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.shutdownSimulator(.simWithNoOS) {
        case .success:
            XCTFail("failure is expected")

        case .failure:
            break
        }
    }

    func testShutdownNonExistingSimulator() {
        switch manager.shutdownSimulator(.sample) {
        case .success:
            XCTFail("failure is expected")

        case .failure:
            break
        }
    }

    func testShutdownSimulatorFails() {
        let failure = Failure.message("Error")
        initializeManager(
            _shutdownSimulator: { _ in
                return .failure(failure)
            },
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.booted, .sample]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.shutdownSimulator(.booted) {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            XCTAssertEqual(failure, error)
            XCTAssertEqual(manager.simulators.values.first?.first, .booted)
            XCTAssertNotNil(manager.processes[Simulator.booted.id])
            XCTAssertNotNil(manager.installedApplications[Simulator.booted.id])
        }
    }

    func testFetchRunningProcessesSuccess() {
        initializeManager(
            _shutdownSimulator: { _ in
                return .success(())
            },
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.booted, .sample]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.fetchRunningProcesses(for: .sample) {
        case .success(let processes):
            XCTAssertEqual(processes, [.sample])
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testFetchRunningProcessesForNonExistingSimulator() {
        switch manager.fetchRunningProcesses(for: .sample) {
        case .success:
            XCTFail("Expected to fail")
        case .failure:
            break
        }
    }

    func testFetchRunningProcessesFailure() {
        let failure = Failure.message("Error")
        initializeManager(
            _shutdownSimulator: { _ in
                return .success(())
            },
            _activeProcesses: { _ in
                return .failure(failure)
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.booted, .sample]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.fetchRunningProcesses(for: .sample) {
        case .success:
            XCTFail("Expected to fail")
        case .failure(let error):
            XCTAssertEqual(failure, error)
        }
    }

    // MARK: - Test fetching installed applications

    func testFetchInstalledApplicationsSuccess() {
        initializeManager(
            _shutdownSimulator: { _ in
                return .success(())
            },
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.fetchInstalledApplications(for: .sample) {
        case .success(let apps):
            XCTAssertEqual(apps, [.fake])
        case .failure(let error):
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testFetchInstalledApplicationsFailure() {
        let failure = Failure.message("Error")
        initializeManager(
            _shutdownSimulator: { _ in
                return .success(())
            },
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .failure(failure)
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.fetchInstalledApplications(for: .sample) {
        case .success:
            XCTFail("Expected to fail")
        case .failure(let error):
            XCTAssertEqual(error, failure)
        }
    }

    func testFetchInstalledApplicationsForNonExistingSimulator() {
        switch manager.fetchInstalledApplications(for: .sample) {
        case .success:
            XCTFail("Expected to fail")
        case .failure:
            break
        }
    }

    func testUninstallInstalledApplicationSuccess() {
        initializeManager(
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _uninstallApp: { _, _ in
                return .success(())
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.booted]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        let _ = manager.uninstall(.fake, simulator: Simulator.booted)

        XCTAssertEqual(manager.installedApplications[Simulator.booted.id], [])
    }

    func testUninstallApplicationFailure() {
        let failure = Failure.message("Error")
        initializeManager(
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _uninstallApp: { _, _ in
                return .failure(failure)
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.booted]])
            },
            _fetchLocale: { _ in .success("en_US") }
        )

        manager.fetchSimulators()

        switch manager.uninstall(.fake, simulator: .booted) {
        case .success:
            XCTFail("Success case not expected to be reached")
        case .failure(let error):
            XCTAssertEqual(error, failure)
            XCTAssertEqual(manager.installedApplications[Simulator.booted.id]?.first, .fake)
        }
    }

    func testUninstallApplicationFromNonExistingSimulator() {
        switch manager.uninstall(.fake, simulator: .booted) {
        case .success:
            XCTFail("Should not succeed")
        case .failure:
            break
        }
    }

    func testUpdateLocationSuccess() {
        initializeManager(
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample]])
            },
            _updateLocation: { _, _, _ in
                return .success(())
            }
        )

        manager.fetchSimulators()

        switch manager.updateLocation(in: .sample, latitude: 12, longtitude: 12) {
        case .success:
            break
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testUpdateLocationFailure() {
        let failure = Failure.message("Error")
        initializeManager(
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample]])
            },
            _updateLocation: { _, _, _ in
                return .failure(failure)
            }
        )

        manager.fetchSimulators()

        switch manager.updateLocation(in: .sample, latitude: 12, longtitude: 12) {
        case .success:
            XCTFail("Should not have succeeded")
        case .failure(let error):
            XCTAssertEqual(error, failure)
        }
    }

    func testUpdateLocationOnNonExistingSimulator() {
        switch manager.updateLocation(in: .sample, latitude: 12, longtitude: 12) {
        case .success:
            XCTFail("Should not have succeeded")
        case .failure:
            break
        }
    }

    func testEraseContentsOnASimulatorThatDoesNotExist() {
        switch manager.eraseContents(in: .booted) {
        case .success:
            XCTFail("Should not have succeeded")
        case .failure:
            break
        }
    }

    func testEraseContentsSuccess() {
        initializeManager(
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _eraseContentAndSettings: { _ in
                return .success(())
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.booted]])
            },
            _fetchLocale: { _ in
                return .success("en_US")
            }
        )

        manager.fetchSimulators()

        switch manager.eraseContents(in: .booted) {
        case .success:
            break
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testEraseContentFailure() {
        let failure: Failure = .message("Error")
        initializeManager(
            _activeProcesses: { _ in
                return .success([.sample])
            },
            _eraseContentAndSettings: { _ in
                return .failure(failure)
            },
            _installedApps: { _ in
                return .success([.fake])
            },
            _fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.booted]])
            },
            _fetchLocale: { _ in
                return .success("en_US")
            }
        )

        manager.fetchSimulators()

        switch manager.eraseContents(in: .booted) {
        case .success:
            XCTFail("Should not have succeeded")
        case .failure(let error):
            XCTAssertEqual(failure, error)
        }
    }
}

extension SimulatorManagerTests {
    func initializeManager(
        _shutdownSimulator:  ((String) -> Result<Void, Failure>)? = nil,
        _openSimulator:  ((String) -> Result<Void, Failure>)? = nil,
        _activeProcesses:  ((String) -> Result<[SimJD.ProcessInfo], Failure>)? = nil,
        _createSimulator: ((String, String, String) -> Result<Void, Failure>)? = nil,
        _eraseContentAndSettings:  ((String) -> Result<Void, Failure>)? = nil,
        _installedApps:  ((String) -> Result<[InstalledAppDetail], Failure>)? = nil,
        _uninstallApp:  ((InstalledAppDetail, String) -> Result<Void, Failure>)? = nil,
        _deleteSimulator: ((String) -> Result<Void, Failure>)? = nil,
        _fetchSimulatorDictionary: (() -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure>)? = nil,
        _updateLocation: ((String, Double, Double) -> Result<Void, Failure>)? = nil,
        _getDeviceList: ( () -> Result<[String], Failure> )? = nil,
        _getRuntimes: ( () -> Result<[String], Failure> )? = nil,
        _fetchLocale: ((String) -> Result<String, Failure>)? = nil
    ) {
        let client = SimulatorClient
            .testing
            .mutate(
                _shutdownSimulator: _shutdownSimulator,
                _openSimulator: _openSimulator,
                _activeProcesses: _activeProcesses,
                _createSimulator: _createSimulator,
                _eraseContentAndSettings: _eraseContentAndSettings,
                _installedApps: _installedApps,
                _uninstallApp: _uninstallApp,
                _deleteSimulator: _deleteSimulator,
                _fetchSimulatorDictionary: _fetchSimulatorDictionary,
                _updateLocation: _updateLocation,
                _getDeviceList: _getDeviceList,
                _getRuntimes: _getRuntimes,
                _fetchLocale: _fetchLocale
            )

        self.manager = .init(client: client)
    }
}

private extension Simulator {
    static let sample: Simulator = .init(
        dataPath: "path",
        dataPathSize: nil,
        logPath: "logpath",
        udid: "123",
        isAvailable: true,
        deviceTypeIdentifier: "id",
        state: "Shutdown",
        name: "name",
        os: .iOS("18"),
        deviceImage: .iphone(.gen3)
    )

    static let sample2: Simulator = .init(
        dataPath: "path2",
        dataPathSize: nil,
        logPath: "logpath2",
        udid: "1234",
        isAvailable: true,
        deviceTypeIdentifier: "id2",
        state: "Shutdown",
        name: "name2",
        os: .iOS("18"),
        deviceImage: .iphone(.gen3)
    )

    static let booted: Self = .init(
        dataPath: "bootedpath2",
        dataPathSize: nil,
        logPath: "logpath2",
        udid: "booted12",
        isAvailable: true,
        deviceTypeIdentifier: "bootedid",
        state: "Booted",
        name: "bootedname",
        os: .iOS("18"),
        deviceImage: .iphone(.gen3)
    )

    static let booted2: Self = .init(
        dataPath: "path2",
        dataPathSize: nil,
        logPath: "logpath2",
        udid: "booted1234",
        isAvailable: true,
        deviceTypeIdentifier: "bootedid2",
        state: "Booted",
        name: "bootedname2",
        os: .iOS("18"),
        deviceImage: .iphone(.gen3)
    )

    static let simWithNoOS = Simulator(
        dataPath: "oslesspath",
        dataPathSize: nil,
        logPath: "oslesslogpath",
        udid: "oslessuuid",
        isAvailable: true,
        deviceTypeIdentifier: "oslessDeviceTypeIdentifier",
        state: "Shutdown",
        name: "oslessSimulator",
        os: nil,
        deviceImage: .iphone(.gen3)
    )
}

private extension SimJD.ProcessInfo {
    static let sample: Self = .init(
        pid: "123",
        status: "123",
        label: "123"
    )
}

private extension InstalledAppDetail {
    static var fake: Self = .init(
        applicationType: "User",
        bundle: "Bundle",
        displayName: "Display",
        bundleIdentifier: "BundleID",
        bundleName: "BundleName",
        bundleVersion: "BundleVersion",
        dataContainer: "DataContainer",
        path: "Path"
    )
}
