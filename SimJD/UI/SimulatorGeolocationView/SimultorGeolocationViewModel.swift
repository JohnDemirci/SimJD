//
//  SimultorGeolocationViewModel.swift
//  SimJD
//
//  Created by John Demirci on 4/3/25.
//

import MapKit
import SwiftUI

@MainActor
@Observable
final class SimulatorGeolocationViewModel {
    enum Event {
        case didFailCoordinateProxy
        case didFailUpdateLocation
        case didUpdateLocation
    }

    private let manager: SimulatorManager
    let sendEvent: (Event) -> Void

    var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: .sanFrancisco,
            span: .oneDegree
        )
    )

    var marker: CLLocationCoordinate2D = .sanFrancisco

    init(
        manager: SimulatorManager = .live,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.manager = manager
        self.sendEvent = sendEvent
    }

    func didTapOnMap(converter: MapProxyConversion, position: CGPoint) {
        if let coordinate = converter.convert(point: position) {
            marker = coordinate
        } else {
            sendEvent(.didFailCoordinateProxy)
        }
    }

    func didSelectSelectLocation() {
        guard let simulator = manager.selectedSimulator else { return }
        switch manager.updateLocation(
            in: simulator,
            latitude: marker.latitude,
            longtitude: marker.longitude
        ) {
        case .success:
            sendEvent(.didUpdateLocation)
        case .failure:
            sendEvent(.didFailUpdateLocation)
        }
    }
}

extension CLLocationCoordinate2D {
    static let sanFrancisco = CLLocationCoordinate2D(
        latitude: 37.773972,
        longitude: -122.431297
    )
}

extension MKCoordinateSpan {
    static let oneDegree: MKCoordinateSpan = .init(latitudeDelta: 1, longitudeDelta: 1)
}
