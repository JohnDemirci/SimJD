//
//  GetRuntimes.swift
//  SimJD
//
//  Created by John Demirci on 3/31/25.
//

import Foundation

extension SimulatorClient {
    static func handleGetRuntimes() -> Result<[String], Failure> {
        switch Shell.shared.execute(.getRuntimes) {
        case .success(let maybeOutput):
            guard
                let output = maybeOutput,
                !output.isEmpty
            else {
                return .failure(Failure.message("no runtimes found"))
            }

            let list = output
                .split(separator: "\n")
                .dropFirst()
                .map { "\($0)" }

            return .success(list)

        case .failure(let failure):
            return .failure(failure)
        }
    }
}
