//
//  Alert.swift
//  SimJD
//
//  Created by John Demirci on 1/9/25.
//

import SwiftUI

struct JDAlert {
    let title: String
    let message: String?
    let button1: AlertButton?
    let button2: AlertButton?

    init(
        title: String,
        message: String? = nil,
        button1: AlertButton? = nil,
        button2: AlertButton? = nil
    ) {
        self.title = title
        self.message = message
        self.button1 = button1
        self.button2 = button2
    }
}

struct AlertButton {
    let title: String
    let action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

struct BasicAlertModifier<Item: Hashable>: ViewModifier {
    @Binding var item: Item?

    private let alert: (Item) -> JDAlert
    private let manager: AlertManager = .shared

    init(
        item: Binding<Item?>,
        alert: @escaping (Item) -> JDAlert
    ) {
        self._item = item
        self.alert = alert
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: item) { _, newValue in
                guard let newValue else { return }
                let alertToBeActivated = alert(newValue)

                switch (alertToBeActivated.button1, alertToBeActivated.button2) {
                case (.none, .none):
                    manager.displayAlert(
                        title: alertToBeActivated.title,
                        message: alertToBeActivated.message ?? ""
                    ) { item = nil }
                    
                case (.none, .some(let button)):
                    manager.displayAlert(
                        title: alertToBeActivated.title,
                        message: alertToBeActivated.message ?? "",
                        button1Title: button.title,
                        button1Action: {
                            button.action()
                            self.item = nil
                        }
                    )

                case (.some(let button), .none):
                    manager.displayAlert(
                        title: alertToBeActivated.title,
                        message: alertToBeActivated.message ?? "",
                        button1Title: button.title,
                        button1Action: {
                            button.action()
                            self.item = nil
                        }
                    )

                case (.some(let button1), .some(let button2)):
                    manager.displayAlert(
                        title: alertToBeActivated.title,
                        message: alertToBeActivated.message ?? "",
                        style: .informational,
                        button1Title: button1.title,
                        button2Title: button2.title,
                        button1Action: {
                            button1.action()
                            self.item = nil
                        },
                        button2Action: {
                            button2.action()
                            self.item = nil
                        }
                    )
                }
            }
    }
}

extension View {
    func nsAlert<Item: Hashable>(item: Binding<Item?>, alert: @escaping (Item) -> JDAlert) -> some View {
        modifier(BasicAlertModifier(item: item, alert: alert))
    }
}
