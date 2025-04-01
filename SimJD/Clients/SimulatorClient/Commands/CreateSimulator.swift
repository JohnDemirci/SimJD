//
//  CreateSimulator.swift
//  SimJD
//
//  Created by John Demirci on 3/31/25.
//

import Foundation

extension SimulatorClient {
    static func handleCreateSimulator(
        name: String,
        deviceIdentifier: String,
        runtimeIdentifier: String
    ) -> Result<Void, Failure> {
        switch Shell.shared.execute(
            .createSimulator(
                name,
                deviceIdentifier,
                runtimeIdentifier
            )
        ) {
        case .success(let maybeOutput):
            guard let output = maybeOutput else {
                return .failure(Failure.message("no output"))
            }

            return .success(())
        case .failure(let failure):
            return .failure(failure)
        }
    }
}
