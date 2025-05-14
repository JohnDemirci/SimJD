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
        case didChangeBatteryState
        case didFailToChangeState
    }

    private let manager: SimulatorManager
    private let sendEvent: (Event) -> Void
    private let simulator: Simulator

    var level: Int
    var state: BatteryState

    init(
        level: Int,
        manager: SimulatorManager,
        simulator: Simulator,
        state: BatteryState,
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
            sendEvent(.didChangeBatteryState)
        case .failure:
            sendEvent(.didFailToChangeState)
        }
    }
}
