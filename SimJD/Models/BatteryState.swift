//
//  BatteryState.swift
//  SimJD
//
//  Created by John Demirci on 5/12/25.
//

enum BatteryState: String, Hashable, Identifiable, CaseIterable {
    case charged
    case charging
    case discharging

    var id: String { rawValue }
}
