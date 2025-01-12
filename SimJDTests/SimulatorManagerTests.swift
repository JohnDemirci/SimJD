//
//  SimulatorManagerTests.swift
//  SimJDTests
//
//  Created by John Demirci on 1/11/25.
//

import XCTest
@testable import SimJD

@MainActor
final class SimulatorManagerTests: XCTestCase {
    private var manager: SimulatorManager!
    private var client: SimulatorClient!

    override func setUp() {
        super.setUp()
        self.client = .testing
            .mutate(
                _fetchSimulatorDictionary: {
                    return .success([
                        .iOS("18"): [.bootedSimulator, .shutdownSimulator]
                    ])
                },
                _fetchLocale: { _ in
                    return .success("en-US")
                }
            )

        self.manager = .init(simulatorClient: self.client)
    }

    override func tearDown() {
        super.tearDown()
        self.manager = nil
        self.client = nil
    }
}

// MARK: - Initialization Tests

extension SimulatorManagerTests {
    func testInitializingSimulatorManagerFetchesSimulators() {
        // manager is already initialized in the ``func setUp()``
        let allSimulators = self.manager.simulators.flatMap(\.value)
        XCTAssertTrue(allSimulators.contains(.bootedSimulator))
        XCTAssertTrue(allSimulators.contains(.shutdownSimulator))
    }

    func testInitializingManagerSetsFirstSimulatorSelectedSimulator() {
        XCTAssertEqual(
            manager.selectedSimulator,
            manager.simulators.values.first?.first
        )
    }
}

// MARK: - Change Selected Simulator Tests

extension SimulatorManagerTests {
    func testChangeSelectedSimulatorChangesSelectedSimulator() {
        let simulator = Simulator.bootedSimulator
        self.manager.selectedSimulator = simulator
        XCTAssertEqual(self.manager.selectedSimulator, simulator)
    }

    /*
     The test version of the SimulatorClient has been designed to fail unless proper return value is given.
     This is done intentionally to make sure unexpected APIs are not called.

     if the mutate function is not being used for the client, it means we are not expecting any api call to be made.
     */
    func testSelectSimulatorWithNonExistingSimulatorDoesNotChangeSelectedSimulator() {
        let simulator = Simulator()
        manager.didSelectSimulator(.bootedSimulator)
        manager.didSelectSimulator(simulator)
        XCTAssertEqual(manager.selectedSimulator, .bootedSimulator)
        XCTAssertNotEqual(simulator, .bootedSimulator)
    }
}

// MARK: - Fetch Simulators Tests

extension SimulatorManagerTests {
    func testFetchSimulatorsFailureResetsState() {
        client.mutate(_fetchSimulatorDictionary: {
            return .failure(Failure.message("error"))
        })

        updateManager()

        manager.fetchSimulators()

        XCTAssertEqual(manager.simulators, [:])
        XCTAssertEqual(manager.locales, [:])
        XCTAssertEqual(manager.installedApplications, [:])
        XCTAssertEqual(manager.processes, [:])
        XCTAssertNil(manager.selectedSimulator)
    }
}

// MARK: - Open Simulator Tests

extension SimulatorManagerTests {
    func testOpenSimulatorSuccess() {
        client.mutate(_openSimulator: { _ in .success(()) })
        updateManager()
        manager.didSelectSimulator(.shutdownSimulator)

        XCTAssertEqual(manager.selectedSimulator?.state, "Shutdown")
        manager.openSimulator(.shutdownSimulator)

        XCTAssertEqual(
            manager.selectedSimulator?.id,
            Simulator.shutdownSimulator.id
        )

        XCTAssertEqual(
            manager.selectedSimulator?.state,
            "Booted"
        )
    }

    func testOpenSimulatorFailure() {
        client.mutate(_openSimulator: { _ in .failure(Failure.message("Error")) })
        updateManager()
        manager.didSelectSimulator(.shutdownSimulator)
        manager.openSimulator(.shutdownSimulator)

        XCTAssertEqual(
            manager.selectedSimulator?.id,
            Simulator.shutdownSimulator.id
        )
        XCTAssertEqual(manager.selectedSimulator?.state, "Shutdown")
    }

    /*
     The test version of the SimulatorClient has been designed to fail unless proper return value is given.
     This is done intentionally to make sure unexpected APIs are not called.

     if the mutate function is not being used for the client, it means we are not expecting any api call to be made.
     */
    func testOpenSimulatorWithNonExistingSimulator() {
        let result = manager.openSimulator(Simulator())
        switch result {
        case .success:
            XCTFail("opening non existing simulator should not result ins uccess")
        case .failure:
            break
        }
    }
}

// MARK: - Test Delete Simulator

extension SimulatorManagerTests {
    func testDeleteSimulatorSuccess() {
        let simulator = Simulator.bootedSimulator
        client.mutate(_deleteSimulator: { _ in .success(()) })
        updateManager()
        manager.deleteSimulator(simulator)

        let allsimulators = manager.simulators.flatMap(\.value)

        XCTAssertNil(manager.locales[simulator.id])
        XCTAssertNil(manager.installedApplications[simulator.id])
        XCTAssertNil(manager.processes[simulator.id])
        XCTAssertFalse(allsimulators.contains(simulator))
    }

    func testDeleteSimulatorFailure() {
        client.mutate(_deleteSimulator: { _ in .failure(Failure.message("Error")) })
        updateManager()
        let result = manager.deleteSimulator(.bootedSimulator)

        let allsimulators = manager.simulators.flatMap(\.value)

        switch result {
        case .success:
            XCTFail("Expected Failure")
        case .failure:
            XCTAssertTrue(allsimulators.contains(.bootedSimulator))
            XCTAssertNotNil(manager.locales[Simulator.bootedSimulator.id])
        }
    }

    func testDeleteSimulatorThatDoesntExist() {
        /*
         The test version of the SimulatorClient has been designed to fail unless proper return value is given.
         This is done intentionally to make sure unexpected APIs are not called.

         if the mutate function is not being used for the client, it means we are not expecting any api call to be made.
         */
        switch manager.deleteSimulator(Simulator()) {
        case .success:
            XCTFail("Expected Failure")
        case .failure:
            break
        }
    }
}

// MARK: - Shutdown Simulator Tests

extension SimulatorManagerTests {
    func testShutdownSimulatorSuccess() {
        let simulator = Simulator.bootedSimulator
        client.mutate(_shutdownSimulator: { _ in .success(()) })
        updateManager()
        manager.shutdownSimulator(simulator)

        let allSimulators = manager.simulators.flatMap(\.value)
        guard let sim = allSimulators.first(where: {
            $0.id == simulator.id
        }) else {
            XCTFail("Simulator must exists")
            return
        }

        XCTAssertEqual(sim.state, "Shutdown")
        XCTAssertEqual(manager.selectedSimulator, sim)
    }

    func testShutdownSimulatorFailure() {
        let simulator = Simulator.bootedSimulator
        client.mutate(_shutdownSimulator: { _ in .failure(Failure.message("Error")) })
        updateManager()
        let result = manager.shutdownSimulator(simulator)

        let allSimulators = manager.simulators.flatMap(\.value)
        let sim = allSimulators.first(where: { $0.id == simulator.id })

        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure:
            XCTAssertEqual(sim?.state, "Booted")
        }
    }

    func testShutdownNonExistingSimulator() {
        /*
         The test version of the SimulatorClient has been designed to fail unless proper return value is given.
         This is done intentionally to make sure unexpected APIs are not called.

         if the mutate function is not being used for the client, it means we are not expecting any api call to be made.
         */

        let simulator = Simulator()
        let result = manager.shutdownSimulator(simulator)

        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure:
            break
        }
    }
}

// MARK: - Fetch Running Processes

extension SimulatorManagerTests {
    func testFetchRunningProcessesSuccess() {
        let simulator = Simulator.bootedSimulator
        client.mutate(_activeProcesses: { _ in .success([.sample, .sample2]) })
        updateManager()

        XCTAssertNil(manager.processes[simulator.id])

        switch manager.fetchRunningProcesses(for: simulator) {
        case .success:
            XCTAssertEqual(manager.processes[simulator.id], [.sample, .sample2])
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testFetchRunniongProcessesFailure() {
        let simulator = Simulator.bootedSimulator
        client.mutate(_activeProcesses: { _ in .failure(Failure.message("Error")) })
        updateManager()
        XCTAssertNil(manager.processes[simulator.id])

        switch manager.fetchRunningProcesses(for: simulator) {
        case .success:
            XCTFail("Expected to fail")
        case .failure:
            XCTAssertNil(manager.processes[simulator.id])
        }
    }

    /*
     The test version of the SimulatorClient has been designed to fail unless proper return value is given.
     This is done intentionally to make sure unexpected APIs are not called.

     if the mutate function is not being used for the client, it means we are not expecting any api call to be made.
     */
    func testFetchRunningProcessesForNonExistingSimulator() {
        switch manager.fetchRunningProcesses(for: Simulator()) {
        case .success:
            XCTFail("Expected to fail")
        case .failure:
            break
        }
    }
}

// MARK: - Fetch Installed Applications Tests

extension SimulatorManagerTests {
    func testFetchInstalledApplicationsSuccess() {
        let simulator = Simulator.bootedSimulator
        client.mutate(_installedApps: { _ in
            return .success([.sample])
        })
        updateManager()

        switch manager.fetchInstalledApplications(for: simulator) {
        case .success(let installedApps):
            XCTAssertEqual(manager.installedApplications[simulator.id], installedApps)
        case .failure:
            XCTFail("Expected to succeed")
        }
    }

    func testFetchInstalledApplicationsFailure() {
        let simulator = Simulator.bootedSimulator
        client.mutate(_installedApps: { _ in
            return .failure(Failure.message("Error"))
        })
        updateManager()

        switch manager.fetchInstalledApplications(for: simulator) {
        case .success:
            XCTFail("Expected to fail")
        case .failure:
            XCTAssertNil(manager.installedApplications[simulator.id])
        }
    }

    /*
     The test version of the SimulatorClient has been designed to fail unless proper return value is given.
     This is done intentionally to make sure unexpected APIs are not called.

     if the mutate function is not being used for the client, it means we are not expecting any api call to be made.
     */
    func testFetchInstalledApplicationsForSimulatorThatDoesNotExist() {
        let simulator = Simulator()

        switch manager.fetchInstalledApplications(for: simulator) {
        case .success:
            XCTFail("Expected to fail")
        case .failure:
            XCTAssertNil(manager.installedApplications[simulator.id])
        }
    }
}

// MARK: - Test Erase Content and Settings

extension SimulatorManagerTests {
    func testEraseContentAndSettingsSuccess() {
        let simulator = Simulator.bootedSimulator
        client.mutate(
            _activeProcesses: { _ in .success([]) },
            _eraseContentAndSettings: { _ in
                return .success(())
            },
            _installedApps: { _ in .success([]) },
            _fetchLocale: { _ in .success("en") }
        )
        updateManager()
        
        switch manager.eraseContents(in: simulator) {
        case .success:
            XCTAssertEqual(manager.processes[simulator.id], [])
            XCTAssertEqual(manager.installedApplications[simulator.id], [])
            XCTAssertEqual(manager.locales[simulator.id], "en")
        case .failure:
            XCTFail("Expected to succeed")
        }
    }

    func testEraseContentAndSettingsFailure() {
        let simulator = Simulator.bootedSimulator

        client.mutate(_eraseContentAndSettings: { _ in
            return .failure(Failure.message("Error"))
        })
        updateManager()

        switch manager.eraseContents(in: simulator) {
        case .success:
            XCTFail("Expected to fail")
        case .failure:
            XCTAssertNil(manager.processes[simulator.id])
        }
    }

    /*
     The test version of the SimulatorClient has been designed to fail unless proper return value is given.
     This is done intentionally to make sure unexpected APIs are not called.

     if the mutate function is not being used for the client, it means we are not expecting any api call to be made.
     */
    func testEraseContentAndSettingsForASimulatorThatDoesNotExist() {
        let simulator = Simulator()
        let result = manager.eraseContents(in: simulator)

        switch result {
        case .success:
            XCTFail("Expected to fail")
        case .failure:
            break
        }
    }
}

// MARK: - Testing Update Location

extension SimulatorManagerTests {
    func testUpdateLocationSuccess() {
        let simulator = Simulator.bootedSimulator
        client.mutate(_updateLocation: { _, _, _ in .success(()) })
        updateManager()

        switch manager.updateLocation(in: simulator, latitude: 0, longtitude: 0) {
        case .success:
            break
        case .failure:
            XCTFail("Expected to succeed")
        }
    }

    func testUpdateLocationFailure() {
        let simulator = Simulator.bootedSimulator
        client.mutate(_updateLocation: { _, _, _ in .failure(Failure.message("Error")) })
        updateManager()
        
        switch manager.updateLocation(in: simulator, latitude: 0, longtitude: 0) {
        case .success:
            XCTFail("Expected to fail")
        case .failure:
            break
        }
    }

    /*
     The test version of the SimulatorClient has been designed to fail unless proper return value is given.
     This is done intentionally to make sure unexpected APIs are not called.

     if the mutate function is not being used for the client, it means we are not expecting any api call to be made.
     */
    func testUpdateLocationForSimulatorThatDoesNotExist() {
        let simulator = Simulator()

        switch manager.updateLocation(in: simulator, latitude: 0, longtitude: 0) {
        case .success:
            XCTFail("Expected to fail")
        case .failure:
            break
        }
    }
}

// MARK: - Helper functions

extension SimulatorManagerTests {
    private func updateManager() {
        self.manager = .init(simulatorClient: self.client)
    }
}

// MARK: - Values for Testiing

extension Simulator {
    static let bootedSimulator: Simulator = .init(
        udid: "SampleID",
        isAvailable: true,
        deviceTypeIdentifier: "iPhone",
        state: "Booted",
        name: "iPhone Simulator",
        os: .iOS("18"),
        deviceImage: .iphone(.gen3)
    )

    static let shutdownSimulator: Simulator = .init(
        udid: "SampleID2",
        isAvailable: true,
        deviceTypeIdentifier: "iPhone",
        state: "Shutdown",
        name: "iPhone Simulator",
        os: .iOS("18"),
        deviceImage: .iphone(.gen3)
    )
}

extension SimJD.ProcessInfo {
    static let sample: SimJD.ProcessInfo = .init(
        pid: "sample",
        status: "status",
        label: "label"
    )

    static let sample2: SimJD.ProcessInfo = .init(
        pid: "sample2",
        status: "status",
        label: "label"
    )
}

extension InstalledAppDetail {
    static let sample: InstalledAppDetail = .init(
        applicationType: "User",
        bundle: "bundle",
        displayName: "sample",
        bundleIdentifier: "bundleID",
        bundleName: "bundleName",
        bundleVersion: "1",
        dataContainer: "container",
        path: "path"
    )
}
