//
//  SimulatorDetailsCoordinatorTests.swift
//  SimJD
//
//  Created by John Demirci on 4/21/25.
//

import XCTest
@testable import SimJD

@MainActor
final class SimulatorDetailsCoordinatorTests: XCTestCase {
    private var coordinator: SimulatorDetailsCoordinator!
    private var manager: SimulatorManager!

    override func setUp() {
        super.setUp()

        self.manager = .init(client: .testing)
        self.coordinator = .init(simManager: self.manager)
    }

    override func tearDown() {
        super.tearDown()

        self.manager = nil
        self.coordinator = nil
    }
}

// MARK: - getJDAlert

extension SimulatorDetailsCoordinatorTests {
    func testGetJDAlertDidDeleteSimulator() {
        let alert = coordinator.getJDAlert(for: .didDeleteSimulator)

        XCTAssertEqual(alert.title, "Simulator deleted")
    }

    func testGetJDAlertDidFailToDeleteSimulator() {
        let alert = coordinator.getJDAlert(for: .didFailToDeleteSimulator)

        XCTAssertEqual(alert.title, "Simulator deletion failed")
    }

    func testGetJDAlertDidSelectDeleteSimulator() {
        let simulator = Simulator()
        let alert = coordinator.getJDAlert(for: .didSelectDeleteSimulator(simulator))

        XCTAssertEqual(alert.title, "Are you sure you want to delete this simulator?")
        XCTAssertEqual(alert.message, "This will delete the simulator entirely")
    }

    func testGetJDAlertDidSelectDeleteSimulatorSuccess() async throws {
        let client = SimulatorClient
            .testing
            .mutate(
                _deleteSimulator: { _ in
                    return .success(())
                },
                _fetchSimulatorDictionary: {
                    return .success([.iOS("18"): [.sample]])
                }
            )

        self.manager = .init(client: client)
        self.manager.fetchSimulators()
        self.coordinator = .init(simManager: self.manager)

        let alert = coordinator.getJDAlert(for: .didSelectDeleteSimulator(.sample))

        XCTAssertEqual(alert.title, "Are you sure you want to delete this simulator?")
        XCTAssertEqual(alert.message, "This will delete the simulator entirely")

        alert.button1?.action()

        try await Task.sleep(for: .seconds(2))

        XCTAssertEqual(coordinator.alert, .didDeleteSimulator)
    }

    func testGetJDAlertDidSelectDeleteSimulatorFailure() async throws {
        let client = SimulatorClient
            .testing
            .mutate(
                _deleteSimulator: { _ in
                    return .failure(Failure.message("Error"))
                },
                _fetchSimulatorDictionary: {
                    return .success([.iOS("18"): [.sample]])
                }
            )

        self.manager = .init(client: client)
        self.manager.fetchSimulators()

        self.coordinator = .init(simManager: self.manager)
        let alert = coordinator.getJDAlert(for: .didSelectDeleteSimulator(.sample))

        XCTAssertEqual(alert.title, "Are you sure you want to delete this simulator?")
        XCTAssertEqual(alert.message, "This will delete the simulator entirely")

        alert.button1?.action()

        try await Task.sleep(for: .seconds(2))

        XCTAssertEqual(coordinator.alert, .didFailToDeleteSimulator)
    }

    func testGetJDAlertDidSelectSimulatorCancelButton() async throws {
        let client = SimulatorClient
            .testing
            .mutate(
                _deleteSimulator: { _ in
                    return .success(())
                },
                _fetchSimulatorDictionary: {
                    return .success([.iOS("18"): [.sample]])
                }
            )

        self.manager = .init(client: client)
        self.manager.fetchSimulators()
        self.coordinator = .init(simManager: self.manager)

        let alert = coordinator.getJDAlert(for: .didSelectDeleteSimulator(.sample))
        alert.button2?.action()
        try await Task.sleep(for: .seconds(2))
        XCTAssertNil(coordinator.alert)
    }

    func testGetJDAlertDidFailToEraseContents() {
        let alert = coordinator.getJDAlert(for: .didFailToEraseContents)

        XCTAssertEqual(alert.title, "Simulator contents erasure failed")
    }

    func testJDAlertDidSelectSimulatorEraseContents() async throws {
        let client = SimulatorClient
            .testing
            .mutate(
                _eraseContentAndSettings: { _ in
                    return .success(())
                },
                _fetchSimulatorDictionary: {
                    return .success([.iOS("18"): [.sample]])
                }
            )
        self.manager = .init(client: client)
        self.manager.fetchSimulators()
        self.coordinator = .init(simManager: self.manager)
        let alert = coordinator.getJDAlert(for: .didSelectEraseData(.sample))

        XCTAssertEqual(alert.title, "Erase All Simulator Data?")
        XCTAssertEqual(alert.message, "This will behave similarly to a factory reset. Are you sure you want to erase all simulator data?")

        alert.button1?.action()

        XCTAssertNil(coordinator.alert)
    }

    func testDidSelectEraseSimulatorFailure() async throws {
        let client = SimulatorClient
            .testing
            .mutate(
                _eraseContentAndSettings: { _ in
                    return .failure(Failure.message("Error"))
                },
                _fetchSimulatorDictionary: {
                    return .success([.iOS("18"): [.sample]])
                }
            )
        self.manager = .init(client: client)
        self.coordinator = .init(simManager: self.manager)
        let alert = coordinator.getJDAlert(for: .didSelectEraseData(.sample))

        XCTAssertEqual(alert.title, "Erase All Simulator Data?")
        XCTAssertEqual(alert.message, "This will behave similarly to a factory reset. Are you sure you want to erase all simulator data?")

        alert.button1?.action()

        try await Task.sleep(for: .seconds(2))

        XCTAssertEqual(coordinator.alert, .didFailToEraseContents)
    }

    func testDidSelectEraseDataAlertDismissButton() async throws {
        let alert = coordinator.getJDAlert(for: .didSelectEraseData(.sample))

        alert.button2?.action()
        try await Task.sleep(for: .seconds(2))
        XCTAssertNil(coordinator.alert)
    }
}

// MARK: - Handle Action Tests
extension SimulatorDetailsCoordinatorTests {
    func testHandleActionDidSelectDeleteSimulator() {
        let simulator = Simulator.sample
        coordinator.handleAction(.simulatorDetailsViewModelEvent(.didSelectDeleteSimulator(simulator)))
        XCTAssertEqual(coordinator.alert, .didSelectDeleteSimulator(simulator))
    }

    func testHandleActionDidSelectEraseContentAndSettings() {
        let simulator = Simulator.sample
        coordinator.handleAction(.simulatorDetailsViewModelEvent(.didSelectEraseContentAndSettings(simulator)))
        XCTAssertEqual(coordinator.alert, .didSelectEraseData(simulator))
    }

    func testHandleActionDidSelectAddMedia() {
        let simulator = Simulator.sample
        coordinator.handleAction(.simulatorDetailsViewModelEvent(.didSelectAddMedia(simulator)))
        XCTAssertEqual(coordinator.sheetDestination, .addMedia(simulator))
    }

    func testHandleActionDidSelectBatterySettings() {
        let simulator = Simulator(
            deviceTypeIdentifier: "something",
            os: .iOS("17"),
            state: "Booted",
            udid: "something"
        )

        let state: BatteryState = .charging
        let level: Int = 100

        coordinator.handleAction(
            .simulatorDetailsViewModelEvent(.didSelectBatterySettings(simulator, state, level))
        )

        XCTAssertEqual(coordinator.sheetDestination, .batterySettings(simulator, state, level))
    }

    func testHandleActionDidSelectBatterySettingsShuitdownSimulator() {
        let simulator = Simulator.sample
        let state: BatteryState = .charging
        let level: Int = 100

        coordinator.handleAction(
            .simulatorDetailsViewModelEvent(.didSelectBatterySettings(simulator, state, level))
        )

        XCTAssertNil(coordinator.sheetDestination)
    }
}

private extension Simulator {
    static let sample = Simulator(
        dataPath: "123",
        dataPathSize: 1,
        deviceImage: .appleWatch,
        deviceTypeIdentifier: "123",
        isAvailable: true,
        logPath: "123",
        name: "123",
        os: .iOS("18"),
        state: "123",
        udid: "123"
    )
}
