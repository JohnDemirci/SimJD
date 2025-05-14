//
//  RetrieveBatteryState.swift
//  SimJD
//
//  Created by John Demirci on 5/13/25.
//

import Foundation

extension SimulatorClient {
    static func handleRetrieveBatteryState(
        id: String
    ) -> Result<(BatteryState, Int), Failure> {
        switch Shell.shared.execute(.retrieveOverrides(id)) {
        case .success(let output):
            return decode(output: output)
        case .failure(let failure):
            return .failure(failure)
        }
    }

    private static func decode(
        output: String?
    ) -> Result<(BatteryState, Int), Failure> {
        guard let output else {
            return .failure(Failure.message("Could not decode the output"))
        }

        let lines = output.split(separator: "\n")
            .map { "\($0)" }

        switch lines.count {
        case 2:
            return .success((BatteryState.charged, 100))
        case 3:
            let lastLine = lines.last!

            let components = lastLine.split(separator: ",")
                .map { "\($0)" }

            var batteryState: BatteryState!
            var level: Int!

            components.forEach { (component: String) in
                if component.contains("State:") {
                    let state = component.split(separator: " ")
                        .map { "\($0)" }
                        .last!

                    switch Int(state) {
                    case 0:
                        batteryState = .discharging
                    case 1:
                        batteryState = .charging
                    case 2:
                        batteryState = .charged
                    default:
                        batteryState = .charged
                    }
                } else if component.contains("Level:") {
                    let levelString = component.split(separator: " ")
                        .map { "\($0)" }
                        .last!
                    
                    level = Int(levelString)!
                }
            }

            return .success((batteryState, level))
        default:
            return .failure(Failure.message("Could not decode the output"))
        }
    }
}
