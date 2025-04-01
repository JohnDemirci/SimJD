//
//  GetDeviceList.swift
//  SimJD
//
//  Created by John Demirci on 3/30/25.
//

extension SimulatorClient {
    static func handleGetDeviceList() -> Result<[String], Failure> {
        switch Shell.shared.execute(.getDeviceTypes) {
        case .success(let maybeOutput):
            guard let output = maybeOutput else {
                return .failure(Failure.message("nil result"))
            }
            guard !output.isEmpty else {
                return .failure(Failure.message("Empty Result"))
            }

            let devices = output.split(separator: "\n")
                .dropFirst()
                .map { "\($0)" }

            return .success(devices)

        case .failure(let failure):
            return .failure(failure)
        }
    }
}
