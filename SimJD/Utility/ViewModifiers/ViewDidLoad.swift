//
//  ViewDidLoad.swift
//  SimJD
//
//  Created by John Demirci on 4/4/25.
//

import SwiftUI

private struct ViewdidLoadModifier: ViewModifier {
    @State private var isLoaded = false
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.isLoaded = false
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !isLoaded else { return }
                self.isLoaded = true
                action()
            }
    }
}

extension View {
    func viewDidLoad(_ action: @escaping () -> Void) -> some View {
        modifier(ViewdidLoadModifier(action: action))
    }
}
