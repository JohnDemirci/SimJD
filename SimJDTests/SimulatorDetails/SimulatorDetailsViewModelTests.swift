//
//  SimulatorDetailsViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 4/22/25.
//

import XCTest
@testable import SimJD

@MainActor
final class SimulatorDetailsViewModelTests: XCTestCase {
    private var viewModel: SimulatorDetailsViewModel!
    private var eventHandler: EventHandler!

    override func setUp() {
        super.setUp()
        self.eventHandler = .init()
        self.viewModel = .init(
            simulatorManager: .init(client: .testing),
            sendEvent: eventHandler.handle(_:)
        )
    }
    
    func testExample() {
        eventHandler = nil
        viewModel = nil
    }
}

// MARK: - Test computed properties

extension SimulatorDetailsViewModelTests {
    func testColumnWidth() {
        XCTAssertEqual(viewModel.columnWidth, 400)
    }

    func testSelectedSimulatorNil() {
        XCTAssertNil(viewModel.selectedSimulator)
    }

    func testSelectedSimulatorNotNill() {
        let client = SimulatorClient
            .testing
            .mutate(_fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.sample]])
            })

        let manager = SimulatorManager(client: client)
        manager.fetchSimulators()

        self.viewModel = .init(
            simulatorManager: manager,
            sendEvent: eventHandler.handle(_:)
        )

        XCTAssertEqual(viewModel.selectedSimulator, .sample)
    }

    func testGetBackgroundColorLightMode() {
        XCTAssertEqual(
            viewModel.getBackgroundColor(scheme: .light),
            ColorPalette.background(.light).color
        )
    }

    func testGetBackgroundColorDarkMode() {
        XCTAssertEqual(
            viewModel.getBackgroundColor(scheme: .dark),
            ColorPalette.background(.dark).color
        )
    }

    func testTabTitleString() {
        for tab in SimulatorDetailsViewModel.Tab.allCases {
            switch tab {
            case .activeProcesses:
                XCTAssertEqual(tab.title, "Active Processes")
            case .documents:
                XCTAssertEqual(tab.title, "Documents")
            case .geolocation:
                XCTAssertEqual(tab.title, "Geolocation")
            case .installedApplications:
                XCTAssertEqual(tab.title, "Installed Applications")
            }
        }
    }
}

// MARK: - Test Handle Action

extension SimulatorDetailsViewModelTests {
    func testDidSelectDeleteSimulator() {
        viewModel.handle(action: .actionsViewEvent(.didSelectDeleteSimulator(.sample)))

        XCTAssertEqual(eventHandler.event, .didSelectDeleteSimulator(.sample))
    }

    func testDidSelectEraseContentAndSettings() {
        viewModel.handle(action: .actionsViewEvent(.didSelectEraseContentAndSettings(.sample)))

        XCTAssertEqual(eventHandler.event, .didSelectEraseContentAndSettings(.sample))
    }

    func testDidSelectBatterySettingsSuccess() {
        let client = SimulatorClient
            .testing
            .mutate(
                _retrieveBatteryState: { _ in
                    return .success((BatteryState.charging, 33))
                }
            )

        let manager = SimulatorManager(client: client)

        self.viewModel = .init(
            simulatorManager: manager,
            sendEvent: { [weak self] (event: SimulatorDetailsViewModel.Event) in
                self?.eventHandler.handle(event)
            }
        )

        viewModel.handle(action: .actionsViewEvent(.didSelectBatterySettings(.sample)))
        XCTAssertEqual(eventHandler.event, .didSelectBatterySettings(.sample, .charging, 33))
    }

    func testDidSelectBatterySettingsFailure() {
        let client = SimulatorClient
            .testing
            .mutate(
                _retrieveBatteryState: { _ in
                    return .failure(Failure.message("Error"))
                }
            )

        let manager = SimulatorManager(client: client)

        self.viewModel = .init(
            simulatorManager: manager,
            sendEvent: { [weak self] (event: SimulatorDetailsViewModel.Event) in
                self?.eventHandler.handle(event)
            }
        )

        viewModel.handle(action: .actionsViewEvent(.didSelectBatterySettings(.sample)))
        XCTAssertEqual(eventHandler.event, .didFailToRetrieveBatteryState)
    }
}

private final class EventHandler {
    var event: SimulatorDetailsViewModel.Event?

    func handle(_ event: SimulatorDetailsViewModel.Event) {
        self.event = event
    }
}

private extension Simulator {
    static let sample: Self = .init(
        dataPath: "path",
        dataPathSize: nil,
        logPath: "path2",
        udid: "123",
        isAvailable: false,
        deviceTypeIdentifier: "identifier",
        state: "Shutdown",
        name: "name",
        os: .iOS("18"),
        deviceImage: .iphone(.gen3)
    )
}
