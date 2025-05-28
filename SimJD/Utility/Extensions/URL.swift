//
//  URL.swift
//  SimJD
//
//  Created by John Demirci on 5/19/25.
//

import Foundation

extension URL {
    static let defaultDerivedDataURL: URL = .homeDirectory
        .appendingPathComponent("Library")
        .appendingPathComponent("Developer")
        .appendingPathComponent("Xcode")
        .appendingPathComponent("DerivedData")
}
