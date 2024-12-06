//
//  UninstallApplication.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

extension SimulatorClient {
    static func handleUninstallApplication(
        _ bundleID: String,
        simulatorID: String
    ) -> Result<Void, Failure> {
        switch Shell.shared.execute(.uninstallApp(simulatorID, bundleID)) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(Failure.message(error.localizedDescription))
        }
    }
}
