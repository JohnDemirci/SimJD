//
//  CoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import SwiftUI

protocol CoordinatingView: View {
    associatedtype Destination = Never
    associatedtype Alert = Never
    associatedtype Sheet = Never
    associatedtype Event = Never
    associatedtype Action = Never

    var destination: Destination? { get set }
    var alert: Alert? { get set }
    var present: Sheet? { get set }

    var sendEvent: (Event) -> Void { get }

    func navigate(to destination: Destination)
    func openSheet(_ present: Sheet)
    func handleAction(_ action: Action)
}

extension CoordinatingView where Destination == Never {
    var destination: Destination? {
        get { nil }
        set {  }
    }

    func navigate(to destination: Destination) { }
}

extension CoordinatingView where Alert == Never {
    var alert: Alert? {
        get { nil }
        set { }
    }
}

extension CoordinatingView where Sheet == Never {
    var present: Sheet? {
        get { nil }
        set { }
    }

    func openSheet(_ present: Sheet) { }
}

extension CoordinatingView where Event == Never {
    var sendEvent: (Event) -> Void { { _ in } }
}

extension CoordinatingView where Action == Never {
    func handleAction(_ action: Action) { }
}
