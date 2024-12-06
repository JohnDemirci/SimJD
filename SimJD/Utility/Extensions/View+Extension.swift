//
//  View+Extension.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func inCase<Content :View>(
        _ condition: Bool,
        @ViewBuilder then content: () -> Content
    ) -> some View {
        if condition {
            content()
        } else {
            self
        }
    }
}
