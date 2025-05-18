//
//  AddMedia.swift
//  SimJD
//
//  Created by John Demirci on 5/15/25.
//

extension SimulatorClient {
    static func handleAddMedia(id: String, path: String) -> Result<Void, Failure> {
        switch Shell.shared.execute(.addMedia(id, path)) {
        case .success(let maybeResult):
            if maybeResult == nil || maybeResult == "" {
                return .success(())
            } else {
                return .failure(Failure.message(maybeResult!))
            }

        case .failure(let error):
            return .failure(error)
        }
    }
}
