//
//  InstalledApplicationDetailViewModel.swift
//  SimJD
//
//  Created by John Demirci on 4/15/25.
//

import SwiftUI

@MainActor
@Observable
final class InstalledApplicationDetailViewModel {
    enum Event {
        case couldNotOpenUserDefaults(InstalledAppDetail)
        case didSelectApplicationSandboxData(InstalledAppDetail)
        case didSelectOpenUserDefaults(InstalledAppDetail)
        case didSelectRemoveUserDefaults(InstalledAppDetail)
        case didSelectUninstallApplication(InstalledAppDetail)
    }

    var selection: InstalledApplicationAction.ID?

    private let installedApplication: InstalledAppDetail
    private let sendEvent: (Event) -> Void

    init(
        installedApplication: InstalledAppDetail,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.installedApplication = installedApplication
        self.sendEvent = sendEvent
    }
}

extension InstalledApplicationDetailViewModel {
    var actions: [InstalledApplicationAction] {
        return [
            .init(name: "Application Sandbox Data", action: { [weak self] in
                guard let self else { return }
                self.sendEvent(.didSelectApplicationSandboxData(self.installedApplication))
            }),
            .init(name: "Open User Defaults", action: { [weak self] in
                guard let self else { return }
                self.sendEvent(.didSelectOpenUserDefaults(self.installedApplication))
            }),
            .init(name: "Remove UserDefaults", action: { [weak self] in
                guard let self else { return }
                self.sendEvent(.didSelectRemoveUserDefaults(self.installedApplication))
            }),
            .init(name: "Uninstall Application", action: { [weak self] in
                guard let self else { return }
                self.sendEvent(.didSelectUninstallApplication(self.installedApplication))
            })
        ]
    }
}

extension InstalledApplicationDetailViewModel {
    func didSelectAction(_ actionIDs: Set<InstalledApplicationAction.ID>) {
        guard let actionID = actionIDs.first else { return }
        let action = self.actions.first { $0.id == actionID }
        action?.action()
    }
}

struct InstalledApplicationAction: Identifiable {
    let name: String
    let action: () -> Void

    var id: String { name }
}
