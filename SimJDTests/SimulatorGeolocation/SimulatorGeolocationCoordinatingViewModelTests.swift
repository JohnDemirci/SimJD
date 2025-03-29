//
//  SimulatorGeolocationCoordinatingViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 1/17/25.
//

import XCTest
@testable import SimJD

final class SimulatorGeolocationCoordinatingViewModelTests: XCTestCase {
    private var viewModel: SimulatorGeolocationCoordinatingViewModel!

    override func setUp() {
        super.setUp()
        viewModel = .init()
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
}

// MARK: - Handle Action Tests

extension SimulatorGeolocationCoordinatingViewModelTests {
    func testHandleActionGeolocationViewEventDidFailCoordinateProxySetsAlert() {
        viewModel.handleAction(.simulatorGeolocationViewEvent(.didFailCoordinateProxy))
        XCTAssertEqual(viewModel.alert, .didFailCoordinateProxy)
    }

    func testHandleActionGeolocationViewEventDidFailUpdateLocationSetsAlert() {
        viewModel.handleAction(.simulatorGeolocationViewEvent(.didFailUpdateLocation))
        XCTAssertEqual(viewModel.alert, .didFailUpdateLocation)
    }

    func testHandleActionGeolocationViewEventDidUpdateLocationSetsAlert() {
        viewModel.handleAction(.simulatorGeolocationViewEvent(.didUpdateLocation))
        XCTAssertEqual(viewModel.alert, .didUpdateLocation)
    }
}
