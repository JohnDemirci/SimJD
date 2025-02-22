//
//  UpdateLocation.swift
//  SimJD
//
//  Created by John Demirci on 12/17/24.
//

extension SimulatorClient {
    static func handleUpdateLocation(
        simulatorID: String,
        latitude: Double,
        longitude: Double
    ) -> Result<Void, Failure> {
        dump("trying to update location for simulator \(simulatorID) lat \(latitude) long \(longitude)")
        dump("full command is \(Shell.Command.updateLocation(simulatorID, latitude, longitude).fullCommand)")
        switch Shell.shared.execute(.updateLocation(simulatorID, latitude, longitude)) {
        case .success:
            return .success(())
        case .failure(let failure):
            return .failure(failure)
        }
    }
}
