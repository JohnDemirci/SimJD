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
    var deviceImage: Device?
    var deviceTypeIdentifier: String?
    var isAvailable: Bool?
    var logPath: String?
    var name: String?
    var os: OS.Name?
    var state: String?
    var udid: String?

    init(
        dataPath: String? = nil,
        dataPathSize: Int? = nil,
        deviceImage: Device? = nil,
        deviceTypeIdentifier: String? = nil,
        isAvailable: Bool? = nil,
        logPath: String? = nil,
        name: String? = nil,
        os: OS.Name? = nil,
        state: String? = nil,
        udid: String? = nil
    ) {
        self.dataPath = dataPath
        self.dataPathSize = dataPathSize
        self.deviceImage = deviceImage
        self.deviceTypeIdentifier = deviceTypeIdentifier
        self.isAvailable = isAvailable
        self.logPath = logPath
        self.name = name
        self.os = os
        self.state = state
        self.udid = udid
    }

    var id: String { udid ?? UUID().uuidString }
}
