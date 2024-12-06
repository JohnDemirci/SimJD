//
//  ShutdownSimulator.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

extension SimulatorClient {
    static func handleShutdownSimulator(id: String) -> Result<Void, Failure> {
        switch Shell.shared.execute(.shotdown(id)) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
