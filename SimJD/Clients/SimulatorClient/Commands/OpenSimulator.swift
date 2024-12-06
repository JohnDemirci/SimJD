//
//  OpenSimulator.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation

extension SimulatorClient {
    static func handleOpenSimulator(_ id: String) -> Result<Void, Failure> {
        switch Shell.shared.execute(.openSimulator(id)) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
