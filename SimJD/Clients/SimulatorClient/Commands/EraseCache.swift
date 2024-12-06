//
//  EraseCache.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

extension SimulatorClient {
    static func handleEraseContentAndSettings(_ id: String) -> Result<Void, Failure> {
        switch Shell.shared.execute(.eraseContents(id)) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
