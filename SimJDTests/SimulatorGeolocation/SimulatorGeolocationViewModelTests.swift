//
//  SimulatorGeolocationViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 4/3/25.
//

import MapKit
import XCTest
@testable import SimJD

@MainActor
final class SimulatorGeolocationViewModelTests: XCTestCase {
    private var viewModel: SimulatorGeolocationViewModel!
    private var eventHandler: EventHandler!
    private var manager: SimulatorManager!

    override func setUp() {
        super.setUp()
        self.eventHandler = .init()
        self.manager = .init(client: .testing)
        self.viewModel = .init(
            manager: manager,
            sendEvent: { [unowned self] in
                eventHandler.handle($0)
            }
        )
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
        eventHandler = nil
        manager = nil
    }
}

extension SimulatorGeolocationViewModelTests {
    func testDidSelectLocationWithoutSelectedSimulatorDoesNothing() {
        viewModel.didSelectSelectLocation()
        /*
         SimulatorManager.testing will cause crash if any of its api is used unless it is mutated and given a result.

         if no apis are called, then this will pass.
         */
    }

    func testDidSelectLocationSuccess() {
        let newClient = SimulatorClient.testing
            .mutate(_updateLocation: { _, _, _ in
                return .success(())
            })

        self.manager = .init(client: newClient)
        self.manager.simulators = [.iOS("18"): [.sample]]
        self.manager.didSelectSimulator(.sample)

        self.viewModel = .init(
            manager: manager,
            sendEvent: { [unowned self] in
                eventHandler.handle($0)
            }
        )

        viewModel.didSelectSelectLocation()
        XCTAssertEqual(eventHandler.didReceiveEvent, .didUpdateLocation)
    }

    func testDidSelectLocationFailure() {
        let newClient = SimulatorClient.testing
            .mutate(_updateLocation: { _, _, _ in
                return .failure(Failure.message("error"))
            })

        self.manager = .init(client: newClient)
        self.manager.simulators = [.iOS("18"): [.sample]]
        self.manager.didSelectSimulator(.sample)

        self.viewModel = .init(
            manager: manager,
            sendEvent: { [unowned self] in
                eventHandler.handle($0)
            }
        )

        viewModel.didSelectSelectLocation()
        XCTAssertEqual(eventHandler.didReceiveEvent, .didFailUpdateLocation)
    }

    func testDidTapOnMapConvertsNilCoordinate() {
        let converter = TestMapProxyConverter()
        viewModel.didTapOnMap(converter: converter, position: .zero)
        XCTAssertEqual(eventHandler.didReceiveEvent, .didFailCoordinateProxy)
    }

    func testDidTapOnMapConvertsNewCoordinate() {
        let newCoordinate = CLLocationCoordinate2D(latitude: 1, longitude: 2)
        let converter = TestMapProxyConverter(newCoordinate)
        viewModel.didTapOnMap(converter: converter, position: .zero)
        XCTAssertNil(eventHandler.didReceiveEvent)
    }
}

private final class EventHandler {
    var didReceiveEvent: SimulatorGeolocationViewModel.Event?

    func handle(_ event: SimulatorGeolocationViewModel.Event) {
        didReceiveEvent = event
    }
}

extension Simulator {
    fileprivate static let sample = Simulator(
        udid: "uuid",
        isAvailable: true,
        deviceTypeIdentifier: "id",
        state: "booted",
        name: "sim",
        os: .iOS("18")
    )
}

fileprivate struct TestMapProxyConverter: MapProxyConversion {
    let result: CLLocationCoordinate2D?
    init(_ result: CLLocationCoordinate2D? = nil) {
        self.result = result
    }
    func convert(point: CGPoint) -> CLLocationCoordinate2D? {
        return result
    }
}
