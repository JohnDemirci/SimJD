//
//  BackToolbarButton.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import SwiftUI

private struct BackButtonModifier: ViewModifier {
    @Environment(\.dismiss) var dismiss

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(
                        action: { dismiss() },
                        label: {
                            Image(systemName: "chevron.left")
                        }
                    )
                }
            }
    }
}

extension View {
    func toolbarBackButton() -> some View {
        modifier(BackButtonModifier())
    }
}
