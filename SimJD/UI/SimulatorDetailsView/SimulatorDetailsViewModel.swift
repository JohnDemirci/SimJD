//
//  SimulatorDetailsViewModel.swift
//  SimJD
//
//  Created by John Demirci on 4/20/25.
//

import SwiftUI

@MainActor
@Observable
final class SimulatorDetailsViewModel {
    enum Action {
        case actionsViewEvent(SimulatorSettingsView.Event)
    }

    enum Event: Equatable {
        case didSelectEraseContentAndSettings(Simulator)
        case didSelectDeleteSimulator(Simulator)
    }

    var selectedTab: Tab = .documents
    private let simulatorManager: SimulatorManager
    private let sendEvent: (Event) -> Void

    init(
        simulatorManager: SimulatorManager = .live,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.simulatorManager = simulatorManager
        self.sendEvent = sendEvent
    }
}

// MARK: - Computed Properties

extension SimulatorDetailsViewModel {
    var columnWidth: CGFloat { 400 }

    var selectedSimulator: Simulator? {
        simulatorManager.selectedSimulator
    }
}

extension SimulatorDetailsViewModel {
    func getBackgroundColor(scheme: ColorScheme) -> Color {
        ColorPalette.background(scheme).color
    }
}

// MARK: - Handling Actions

extension SimulatorDetailsViewModel {
    func handle(action: Action) {
        switch action {
        case .actionsViewEvent(let event):
            switch event {
            case .didSelectDeleteSimulator(let sim):
                sendEvent(.didSelectDeleteSimulator(sim))
            case .didSelectEraseContentAndSettings(let sim):
                sendEvent(.didSelectEraseContentAndSettings(sim))
            }
        }
    }
}

extension SimulatorDetailsViewModel {
    enum Tab: Hashable, CaseIterable {
        case activeProcesses
        case documents
        case geolocation
        case installedApplications

        var title: String {
            switch self {
            case .activeProcesses:          return "Active Processes"
            case .documents:                return "Documents"
            case .geolocation:              return "Geolocation"
            case .installedApplications:    return "Installed Applications"
            }
        }
    }
}
