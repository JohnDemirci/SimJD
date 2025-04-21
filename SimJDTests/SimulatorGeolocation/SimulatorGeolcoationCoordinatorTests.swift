//
//  SimulatorGeolcoationCoordinatorTests.swift
//  SimJD
//
//  Created by John Demirci on 4/3/25.
//

import XCTest
@testable import SimJD

final class SimulatorGeolcoationCoordinatorTests: XCTestCase {
    private var coordinator: SimulatorGeolocationCoordinator!

    override func setUp() {
        super.setUp()
        coordinator = .init()
    }

    override func tearDown() {
        super.tearDown()
        coordinator = nil
    }
}

extension SimulatorGeolcoationCoordinatorTests {
    func testDidFailCoordinateProxySetsAlert() {
        coordinator.handleAction(.simulatorGeolocationViewModelEvent(.didFailCoordinateProxy))

        XCTAssertEqual(coordinator.alert, .didFailCoordinateProxy)
    }

    func testDidFailUpdateLocation() {
        coordinator.handleAction(.simulatorGeolocationViewModelEvent(.didFailUpdateLocation))

        XCTAssertEqual(coordinator.alert, .didFailUpdateLocation)
    }

    func testDidUpdateLocation() {
        coordinator.handleAction(.simulatorGeolocationViewModelEvent(.didUpdateLocation))

        XCTAssertEqual(coordinator.alert, .didUpdateLocation)
    }

    func testAlertID() {
        let didFailCoordinateProxy = SimulatorGeolocationCoordinator.Alert.didFailCoordinateProxy

        let didFailUpdateLocation = SimulatorGeolocationCoordinator.Alert.didFailUpdateLocation

        let didUpdateLocation = SimulatorGeolocationCoordinator.Alert.didUpdateLocation

        let didUpdateLocation2 = SimulatorGeolocationCoordinator.Alert.didUpdateLocation

        XCTAssertEqual(didUpdateLocation, didUpdateLocation2)
        XCTAssertEqual(didUpdateLocation.id, didUpdateLocation2.id)
        XCTAssertNotEqual(didFailCoordinateProxy, didFailUpdateLocation)
        XCTAssertNotEqual(didFailUpdateLocation, didUpdateLocation2)
    }
}
