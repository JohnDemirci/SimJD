//
//  UpdateBatteryState.swift
//  SimJD
//
//  Created by John Demirci on 5/13/25.
//

import Foundation

extension SimulatorClient {
    static func handleUpdateBatteryState(
        id: String,
        state: BatteryState,
        level: Int
    ) -> Result<Void, Failure> {
        switch Shell.shared.execute(
            .batteryStatusUpdate(id, state.rawValue, "\(level)")
        ) {
        case .success(let string):
            if string == "" || string == nil {
                return .success(())
            } else {
                return .failure(Failure.message("Failed to update the status bar of the simulator"))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
