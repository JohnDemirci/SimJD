//
//  KeyboardEvent.swift
//  SimJD
//
//  Created by John Demirci on 5/6/25.
//

import SwiftUI

actor KeyboardEvent {
    private var actionBlock: (@Sendable () -> Void)?
    private var holder: Any?

    func set(action: @Sendable @escaping () -> Void) {
        actionBlock = action
    }

    private init() {}

    static let shared: KeyboardEvent = KeyboardEvent()

    func watchEvent() {
        self.holder = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard event.charactersIgnoringModifiers != "e" else {
                Task { [weak self] in
                    await self?.performAction()
                }
                return nil
            }

            return event
        }
    }

    private func performAction() {
        actionBlock?()
    }

    func removeObservation() {
        if let holder {
            NSEvent.removeMonitor(holder)
        }
    }
}
