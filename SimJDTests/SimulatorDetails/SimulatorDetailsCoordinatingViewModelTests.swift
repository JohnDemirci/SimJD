//
//  SimulatorDetailsCoordinatingViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 3/29/25.
//

import XCTest
@testable import SimJD

@MainActor
final class SimulatorDetailsCoordinatingViewModelTests: XCTestCase {
    private var viewModel: SimulatorDetailsCoordinatingViewModel!

    override func setUp() {
        super.setUp()
        viewModel = .init()
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
}

extension SimulatorDetailsCoordinatingViewModelTests {
    func testDidSelectSimulator() {
        viewModel.handleAction(.simulatorDetailsViewEvent(.didSelectDeleteSimulator(.bootedSimulator)))

        XCTAssertEqual(viewModel.alert, .didSelectDeleteSimulator(Simulator.bootedSimulator))
    }

    func testDidSelectEraseSimulatorData() {
        viewModel.handleAction(.simulatorDetailsViewEvent(.didSelectEraseContentAndSettings(.bootedSimulator)))

        XCTAssertEqual(viewModel.alert, .didSelectEraseData(Simulator.bootedSimulator))
    }
}
