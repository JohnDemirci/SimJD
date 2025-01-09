//
//  Binding+Extension.swift
//  SimJD
//
//  Created by John Demirci on 1/9/25.
//

import SwiftUI

extension Binding {
    public init<V>(_ base: Binding<V?>) where Value == Bool {
        self = base._isPresent
    }
}

extension Optional {
    fileprivate var _isPresent: Bool {
        get { self != nil }
        set {
            guard !newValue else { return }
            self = nil
        }
    }
}
