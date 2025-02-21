//
//  UninstallApplication.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

extension SimulatorClient {
    static func handleUninstallApplication(
        _ app: InstalledAppDetail,
        simulatorID: String
    ) -> Result<Void, Failure> {
        if app.applicationType == "System" {
            return .failure(.message("cannot remove system apps"))
        }

        guard let bundleID = app.bundleIdentifier else {
            return .failure(.message("No Bundle Identifier"))
        }

        switch Shell.shared.execute(.uninstallApp(simulatorID, bundleID)) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(Failure.message(error.localizedDescription))
        }
    }
}
