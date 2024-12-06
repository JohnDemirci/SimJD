//
//  DeleteSimulator.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

extension SimulatorClient {
    static func handleDeleteSimulator(_ uuid: String) -> Result<Void, Failure> {
        switch Shell.shared.execute(.deleteSimulator(uuid)) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
