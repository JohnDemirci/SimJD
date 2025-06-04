//
//  Set+ResourceValue.swift
//  SimJD
//
//  Created by John Demirci on 5/31/25.
//

import Foundation

extension Set where Element == URLResourceKey {
    static var `default`: Set<URLResourceKey> {
        [
            .isDirectoryKey,
            .creationDateKey,
            .contentModificationDateKey,
            .contentTypeKey,
            .totalFileSizeKey
        ]
    }
}
