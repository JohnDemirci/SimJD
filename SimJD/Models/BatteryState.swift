//
//  BatteryState.swift
//  SimJD
//
//  Created by John Demirci on 5/12/25.
//

enum BatteryState: String, Hashable, Identifiable, CaseIterable {
    case charging
    case discharging
    case charged

    var id: String { rawValue }
}
