//
//  RunningProcessesCoordinatingViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 1/19/25.
//

import XCTest
@testable import SimJD

@MainActor
final class RunningProcessesCoordinatingViewModelTests: XCTestCase {
    private var viewModel: RunningProcessesCoordinatingViewModel!

    override func setUp() {
        super.setUp()
        viewModel = .init()
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
}

extension RunningProcessesCoordinatingViewModelTests {
    func testHandleAction() {
        viewModel.handleAction(.runningProcessesViewEvent(.didFailToFetchProcesses))
        XCTAssertEqual(viewModel.alert, .fetchError)
    }
}
