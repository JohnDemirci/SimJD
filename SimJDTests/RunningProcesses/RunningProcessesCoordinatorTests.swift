//
//  RunningProcessesCoordinatorTests.swift
//  SimJD
//
//  Created by John Demirci on 4/3/25.
//

import XCTest
@testable import SimJD

@MainActor
final class RunningProcessesCoordinatorTests: XCTestCase {
    private var coordinator: RunningProcessesCoordinator!

    override func setUp() {
        super.tearDown()
        self.coordinator = .init()
    }

    override func tearDown() {
        super.tearDown()
        self.coordinator = nil
    }
}

extension RunningProcessesCoordinatorTests {
    func testRunningProcessesViewEvent() {
        coordinator.handleAction(.runningProcessesViewEvent(.didFailToFetchProcesses))
        XCTAssertEqual(coordinator.alert, .fetchError)
    }

    func testAlertID() {
        let alert = RunningProcessesCoordinator.Alert.fetchError
        let alert2 = RunningProcessesCoordinator.Alert.fetchError

        XCTAssertEqual(alert.id, alert2.id)
    }
}
