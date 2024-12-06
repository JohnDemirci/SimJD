//
//  OptionalView.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import SwiftUI

struct OptionalView<T, V: View, PV: View>: View {
    private let data: T?
    @ViewBuilder private let unwrappedData: (T) -> V
    @ViewBuilder private let placeholderView: () -> PV

    init(
        data: T?,
        unwrappedData: @escaping (T) -> V,
        placeholderView: @escaping () -> PV
    ) {
        self.data = data
        self.unwrappedData = unwrappedData
        self.placeholderView = placeholderView
    }

    var body: some View {
        if let data {
            unwrappedData(data)
        } else {
            placeholderView()
        }
    }
}

extension OptionalView where PV == EmptyView {
    init (
        _ data: T?,
        @ViewBuilder unwrappedData: @escaping (T) -> V
    ) {
        self.data = data
        self.unwrappedData = unwrappedData
        self.placeholderView = { EmptyView() }
    }
}
