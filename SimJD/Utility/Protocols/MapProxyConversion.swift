//
//  MapProxyConversion.swift
//  SimJD
//
//  Created by John Demirci on 1/19/25.
//

import Foundation
import MapKit
import SwiftUI

protocol MapProxyConversion {
    func convert(point: CGPoint) -> CLLocationCoordinate2D?
}

struct MapProxyConverter<T: CoordinateSpaceProtocol>: MapProxyConversion {
    let proxy: MapProxy
    let coordinateSpace: T

    func convert(point: CGPoint) -> CLLocationCoordinate2D? {
        proxy.convert(point, from: coordinateSpace)
    }
}
