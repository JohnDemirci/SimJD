//
//  Dictionary.swift
//  SimJD
//
//  Created by John Demirci on 4/16/25.
//

import Foundation

extension Dictionary {
    mutating func handleResult(
        _ result: Result<Value, Failure>,
        for key: Key
    ) {
        switch result {
        case .success(let value):
            self[key] = value
        case .failure:
            break
        }
    }
}
