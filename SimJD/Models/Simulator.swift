//
//  Simulator.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation
import SwiftUI

struct Simulator: Codable, Hashable, Identifiable {
    var dataPath: String?
    var dataPathSize: Int?
    var logPath: String?
    var udid: String?
    var isAvailable: Bool?
    var deviceTypeIdentifier: String?
    var state: String?
    var name: String?
    var os: OS.Name?
    var deviceImage: Device?

    init(
        dataPath: String? = nil,
        dataPathSize: Int? = nil,
        logPath: String? = nil,
        udid: String? = nil,
        isAvailable: Bool? = nil,
        deviceTypeIdentifier: String? = nil,
        state: String? = nil,
        name: String? = nil,
        os: OS.Name? = nil,
        deviceImage: Device? = nil
    ) {
        self.dataPath = dataPath
        self.dataPathSize = dataPathSize
        self.logPath = logPath
        self.udid = udid
        self.isAvailable = isAvailable
        self.deviceTypeIdentifier = deviceTypeIdentifier
        self.state = state
        self.name = name
        self.os = os
        self.deviceImage = deviceImage
    }

    var id: String { udid ?? UUID().uuidString }
}
