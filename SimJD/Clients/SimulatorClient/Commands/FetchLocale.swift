//
//  FetchLocale.swift
//  SimJD
//
//  Created by John Demirci on 1/10/25.
//

import Foundation

extension SimulatorClient {
    static func handleFetchLocale(_ id: String) -> Result<String, Failure> {
        switch Shell.shared.execute(.simulatorLocale(id)) {
        case .success(let output):
            guard let output else {
                return .failure(Failure.message("Could not convert the simulator locale output to a string."))
            }

            return .success(
                output
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .replacingOccurrences(of: "\"", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )

        case .failure(let failure):
            return .failure(failure)
        }
    }
}
