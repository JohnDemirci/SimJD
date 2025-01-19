//
//  SimulatorGeolocationViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 1/18/25.
//

import MapKit
import XCTest
@testable import SimJD

@MainActor
final class SimulatorGeolocationViewModelTests: XCTestCase {
    private var viewModel: SimulatorGeolocationViewModel!
    private var eventHandler: EventHandler!

    override func setUp() {
        super.setUp()
        eventHandler = EventHandler()
        viewModel = SimulatorGeolocationViewModel { [weak self] event in
            guard let self else {
                XCTFail("self should not be nil")
                return
            }
            eventHandler.handleEvent(event)
        }
    }

    override func tearDown() {
        super.tearDown()
        eventHandler = nil
        viewModel = nil
    }
}

// MARK: - Testing didSelectLocation

extension SimulatorGeolocationViewModelTests {
    func testDidSelectSelectLocationSuccess() {
        let client = SimulatorClient
            .testing
            .mutate(
                _fetchSimulatorDictionary: {
                    return .success([.iOS("18"): [.bootedSimulator]])
                },
                _updateLocation: { _, _, _ in
                    return .success(())
                },
                _fetchLocale: { _ in .failure(Failure.message("Error")) }
            )

        let manager = SimulatorManager(simulatorClient: client)
        manager.didSelectSimulator(.bootedSimulator)

        viewModel.didSelectSelectLocation(manager: manager)

        XCTAssertEqual(eventHandler.didReceiveEvent, .didUpdateLocation)
    }

    func testDidSelectSelectLocationFailure() {
        let client = SimulatorClient
            .testing
            .mutate(
                _fetchSimulatorDictionary: {
                    return .success([.iOS("18"): [.bootedSimulator]])
                },
                _updateLocation: { _, _, _ in
                    return .failure(Failure.message("Error"))
                },
                _fetchLocale: { _ in .failure(Failure.message("Error")) }
            )

        let manager = SimulatorManager(simulatorClient: client)
        manager.didSelectSimulator(.bootedSimulator)

        viewModel.didSelectSelectLocation(manager: manager)

        XCTAssertEqual(eventHandler.didReceiveEvent, .didFailUpdateLocation)
    }

    func testDidSelectSelectLocationOnNonSelectedSimulatorSendNoEvent() {
        let client = SimulatorClient
            .testing
            .mutate(
                _fetchSimulatorDictionary: {
                    return .failure(Failure.message("Error1"))
                },
                _updateLocation: { _, _, _ in
                    return .failure(Failure.message("Error"))
                },
                _fetchLocale: { _ in .failure(Failure.message("Error")) }
            )

        let manager = SimulatorManager(simulatorClient: client)
        viewModel.didSelectSelectLocation(manager: manager)

        XCTAssertNil(eventHandler.didReceiveEvent)
    }
}

// MARK: - Testing DidTapOnMap

extension SimulatorGeolocationViewModelTests {
    func testDidTapOnMapSuccess() {
        let conversion = FakeConversion(
            expectedReturnValue: .some(.init(latitude: 1, longitude: 1))
        )

        viewModel.didTapOnMap(
            converter: conversion,
            position: .init(x: 1, y: 1)
        )

        XCTAssertEqual(viewModel.marker.latitude, conversion.expectedReturnValue?.latitude)
        XCTAssertEqual(viewModel.marker.longitude, conversion.expectedReturnValue?.longitude)
        XCTAssertNil(eventHandler.didReceiveEvent)
    }

    func testDidTapMapSendsFauilureEvent() {
        let conversion = FakeConversion(
            expectedReturnValue: nil
        )

        viewModel.didTapOnMap(
            converter: conversion,
            position: .init(x: 1, y: 1)
        )

        XCTAssertEqual(eventHandler.didReceiveEvent, .didFailCoordinateProxy)
    }
}

@MainActor
private final class EventHandler {
    fileprivate var didReceiveEvent: SimulatorGeolocationViewModel.Event?

    func handleEvent(_ event: SimulatorGeolocationViewModel.Event) {
        didReceiveEvent = event
    }
}

fileprivate final class FakeConversion: MapProxyConversion {
    fileprivate let expectedReturnValue: CLLocationCoordinate2D?

    init(expectedReturnValue: CLLocationCoordinate2D?) {
        self.expectedReturnValue = expectedReturnValue
    }

    func convert(point: CGPoint) -> CLLocationCoordinate2D? {
        return expectedReturnValue
    }
}
