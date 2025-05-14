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
            level: 100,
            manager: SimulatorManager(client: .testing),
            simulator: .sample,
            state: .charged,
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
            level: 33,
            manager: manager,
            simulator: .sample,
            state: .discharging,
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
            level: 33,
            manager: manager,
            simulator: .sample,
            state: .discharging,
            sendEvent: { [weak self] (event: BatterySettingsViewModel.Event) in
                self?.eventHandler.handleEvent(event)
            }
        )

        viewModel.didSelectDone()
        XCTAssertEqual(eventHandler.event, .didChangeBatteryState)
    }
}

private extension Simulator {
    static let sample: Simulator = Simulator(
        dataPath: "path",
        dataPathSize: 1,
        deviceImage: .iphone(.gen2), deviceTypeIdentifier: "identifier", isAvailable: true,
        logPath: "log",
        name: "name",
        os: .iOS("18"), state: "Booted", 
        udid: "id"
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
