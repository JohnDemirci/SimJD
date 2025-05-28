//
//  IfView.swift
//  SimJD
//
//  Created by John Demirci on 5/21/25.
//

import SwiftUI

struct IfView<TrueView: View, FalseView: View>: View {
    private let boolean: Bool
    @ViewBuilder private let trueView: () -> TrueView
    @ViewBuilder private let falseView: () -> FalseView

    init(
        _ boolean: Bool,
        trueView: @escaping () -> TrueView,
        falseView: @escaping () -> FalseView
    ) {
        self.boolean = boolean
        self.trueView = trueView
        self.falseView = falseView
    }

    var body: some View {
        if boolean {
            trueView()
        } else {
            falseView()
        }
    }
}

extension IfView where FalseView == EmptyView {
    init (
        _ boolean: Bool,
        @ViewBuilder trueView: @escaping () -> TrueView
    ) {
        self.boolean = boolean
        self.trueView = trueView
        self.falseView = { EmptyView() }
    }
}

