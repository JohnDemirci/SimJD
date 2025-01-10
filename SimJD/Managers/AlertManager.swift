//
//  AlertManager.swift
//  SimJD
//
//  Created by John Demirci on 1/9/25.
//

import SwiftUI
import AppKit

/// Alerts in SwiftUI are hierarchy based
/// When the parent view has the alert modifier, the alert modifiers in child views won't work
/// To get around this, we are going to be used the NSAlert
@MainActor
final class AlertManager {
    private(set) var isDisplayingAlert: Bool = false

    static let shared = AlertManager()

    @ObservationIgnored
    private lazy var window: NSWindow? = {
        NSApplication.shared.keyWindow
    }()

    private init() { }

    func displayAlert(
        title: String,
        message: String,
        style: NSAlert.Style = .informational,
        completion: (() -> Void)?
    ) {
        guard let window else { return }
        guard !isDisplayingAlert else { return }
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.addButton(withTitle: "OK")

        alert.beginSheetModal(for: window) { [weak self] response in
            self?.isDisplayingAlert = true
            defer { self?.isDisplayingAlert = false }
            if response == .alertFirstButtonReturn {
                completion?()
            }
        }
    }

    func displayAlert(
        title: String,
        message: String,
        style: NSAlert.Style = .informational,
        button1Title: String,
        button2Title: String,
        button1Action: @escaping () -> Void,
        button2Action: @escaping () -> Void
    ) {
        guard let window else { return }
        guard !isDisplayingAlert else { return }
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.addButton(withTitle: button1Title)
        alert.addButton(withTitle: button2Title)

        alert.beginSheetModal(for: window) { [weak self] response in
            self?.isDisplayingAlert = true
            defer { self?.isDisplayingAlert = false }
            if response == .alertFirstButtonReturn {
                button1Action()
            } else if response == .alertSecondButtonReturn {
                button2Action()
            }
        }
    }

    func displayAlert(
        title: String,
        message: String,
        style: NSAlert.Style = .informational,
        button1Title: String,
        button1Action: @escaping () -> Void
    ) {
        guard let window else { return }
        guard !isDisplayingAlert else { return }

        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.addButton(withTitle: button1Title)

        alert.beginSheetModal(for: window) { [weak self] response in
            self?.isDisplayingAlert = true
            defer { self?.isDisplayingAlert = false }
            if response == .alertFirstButtonReturn {
                button1Action()
            }
        }
    }
}
