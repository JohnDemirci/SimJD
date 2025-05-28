//
//  Setting.swift
//  SimJD
//
//  Created by John Demirci on 5/20/25.
//

import Foundation

enum Setting {
    case derivedDataPath
    case enableLogging
    case selectedSimulator
    case sidebarVisibility

    var key: String {
        return switch self {
        case .derivedDataPath:      "derivedDataPath"
        case .enableLogging:        "enableLogging"
        case .selectedSimulator:    "selectedSimulator"
        case .sidebarVisibility:    "sidebarVisibility"
        }
    }
}
