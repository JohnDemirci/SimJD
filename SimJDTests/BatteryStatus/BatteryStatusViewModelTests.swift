//
//  BatteryStatusViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 5/12/25.
//

import XCTest
@testable import SimJD

@MainActor
final class BatteryStatusViewModelTests: XCTestCase {
    private var viewModel: BatterySettingsViewModel!
    private var eventHandler: EventHandler!

    override func setUp() {
        super.setUp()
        eventHandler = EventHandler()

        viewModel = BatterySettingsViewModel(
            simulator: .sample,
            manager: SimulatorManager(client: .testing),
            state: .charged,
            level: 100,
            sendEvent: { [weak self] (event: BatterySettingsViewModel.Event) in
                self?.eventHandler.handleEvent(event)
            }
        )
    }

    override func tearDown() {
        super.tearDown()
        self.eventHandler = nil
        self.viewModel = nil
    }

    func testDidSelectDoneFailure() {
        let client = SimulatorClient
            .testing
            .mutate(
                _updateBatteryState: { _, _, _ in
                    return .failure(Failure.message("error"))
                }
            )

        let manager = SimulatorManager(client: client)

        viewModel = BatterySettingsViewModel(
            simulator: .sample,
            manager: manager,
            state: .discharging,
            level: 33,
            sendEvent: { [weak self] (event: BatterySettingsViewModel.Event) in
                self?.eventHandler.handleEvent(event)
            }
        )

        viewModel.didSelectDone()
        XCTAssertEqual(eventHandler.event, .didFailToChangeState)
    }

    func testDidSelectDoneSuccess() {
        let client = SimulatorClient
            .testing
            .mutate(
                _updateBatteryState: { _, _, _ in
                    return .success(())
                }
            )

        let manager = SimulatorManager(client: client)

        viewModel = BatterySettingsViewModel(
            simulator: .sample,
            manager: manager,
            state: .discharging,
            level: 33,
            sendEvent: { [weak self] (event: BatterySettingsViewModel.Event) in
                self?.eventHandler.handleEvent(event)
            }
        )

        viewModel.didSelectDone()
        XCTAssertEqual(eventHandler.event, .didChangeState)
    }
}

private extension Simulator {
    static let sample: Simulator = Simulator(
        dataPath: "path",
        dataPathSize: 1,
        logPath: "log",
        udid: "id",
        isAvailable: true,
        deviceTypeIdentifier: "identifier",
        state: "Booted",
        name: "name",
        os: .iOS("18"),
        deviceImage: .iphone(.gen2)
    )
}

@MainActor
@Observable
fileprivate final class EventHandler {
    var event: BatterySettingsViewModel.Event?

    func handleEvent(_ event: BatterySettingsViewModel.Event) {
        self.event = event
    }
}
