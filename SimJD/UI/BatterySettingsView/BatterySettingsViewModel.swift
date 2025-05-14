//
//  BatterySettingsViewModel.swift
//  SimJD
//
//  Created by John Demirci on 5/12/25.
//

import SwiftUI

@MainActor
@Observable
final class BatterySettingsViewModel {
    enum Event {
        case didFailToChangeState
        case didChangeState
    }

    private let simulator: Simulator
    private let manager: SimulatorManager
    private let sendEvent: (Event) -> Void

    var state: BatteryState
    var level: Int

    init(
        simulator: Simulator,
        manager: SimulatorManager,
        state: BatteryState,
        level: Int,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.simulator = simulator
        self.manager = manager
        self.state = state
        self.level = level
        self.sendEvent = sendEvent
    }

    func didSelectDone() {
        switch manager.updateBatteryState(id: simulator.id, state: state, level: level) {
        case .success:
            sendEvent(.didChangeState)
        case .failure:
            sendEvent(.didFailToChangeState)
        }
    }
}
