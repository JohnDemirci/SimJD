//
//  RunningProcessesViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 4/3/25.
//

import XCTest
@testable import SimJD

@MainActor
final class RunningProcessesViewModelTests: XCTestCase {
    private var viewModel: RunningProcessesViewModel!
    private var eventHandler: EventHandler!
    private var manager: SimulatorManager!
    private var client: SimulatorClient!

    override func setUp() {
        super.setUp()
        self.client = SimulatorClient.testing
            .mutate(
                _activeProcesses: { _ in
                    return .success([
                        .init(label: "1", pid: "1", status: "1")
                    ])
                },
                _fetchLocale: { _ in
                    return .success("en-US")
                },
                _installedApps: { _ in
                    return  .success([])
                },
                _openSimulator: { _ in
                    return .success(())
                }
            )
        self.manager = SimulatorManager(client: client)
        self.eventHandler = .init()
    }

    override func tearDown() {
        super.tearDown()
        self.eventHandler = nil
        self.viewModel = nil
    }
}

extension RunningProcessesViewModelTests {
    func testEmptyProcessesFetchesProcesses() {
        manager.simulators = [.iOS("18"): [.sample]]
        manager.didSelectSimulator(.sample)

        self.viewModel = .init(
            simManager: manager,
            { _ in
                XCTFail("did not expect to receive event")
            }
        )

        self.viewModel.emptyProcesses()
        XCTAssertEqual(
            viewModel.processes,
            [.init(label: "1", pid: "1", status: "1")]
        )
    }

    func testProcessesReturnEmptyArrayWhenNoSimulatorSelected() {
        let manager = SimulatorManager()
        self.viewModel = .init(simManager: manager, { _ in
            XCTFail("did not expect to receive event")
        })

        viewModel.emptyProcesses()
        XCTAssertEqual(viewModel.processes, [])
        XCTAssertNil(manager.selectedSimulator)
    }

    func testFailedProcessFetchSendsEvent() {
        let newclient = self.client
            .mutate(_activeProcesses: { _ in
                return .failure(Failure.message("error"))
            })

        self.manager = .init(client: newclient)
        self.viewModel = .init(
            simManager: manager,
            eventHandler.handle(_:)
        )
        self.manager.simulators = [.iOS("18"): [.sample]]
        self.manager.didSelectSimulator(.sample)

        viewModel.emptyProcesses()

        XCTAssertEqual(eventHandler.receivedEvent, .didFailToFetchProcesses)
    }
}

@MainActor
private final class EventHandler {
    var receivedEvent: RunningProcessesViewModel.Event?

    func handle(_ event: RunningProcessesViewModel.Event) {
        receivedEvent = event
    }
}

extension Simulator {
    fileprivate static let sample = Simulator(
        deviceTypeIdentifier: "id",
        isAvailable: true,
        name: "sim",
        os: .iOS("18"),
        state: "booted",
        udid: "uuid"
    )
}
