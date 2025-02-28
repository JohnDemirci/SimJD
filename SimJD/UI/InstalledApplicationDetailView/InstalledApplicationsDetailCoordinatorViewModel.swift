//
//  InstalledApplicationsDetailCoordinatorViewModel.swift
//  SimJD
//
//  Created by John Demirci on 2/28/25.
//

import SwiftUI

@MainActor
@Observable
final class InstalledApplicationsDetailCoordinatorViewModel {
    enum Action {
        case installedApplicationDetailViewEvent(InstalledApplicationDetailView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case couldNotOpenUserDefaults
        case couldNotRemoveApplication
        case couldNotRemoveUserDefaults
        case didSelectRemoveUserDefaults
        case didSelectUnisntallApplication(Simulator)
        case didUnisntallApplication(InstalledAppDetail)
        case didRemoveUserDefaults

        var id: AnyHashable { self }
    }

    var alert: Alert?
}
