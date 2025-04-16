//
//  InstalledApplicationsCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct InstalledApplicationsCoordinatingView: View {
    @State private var coordinator = InstalledApplicationsCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.destination) {
            InstalledApplicationsView(
                viewModel: .init(
                    sendEvent: {
                        coordinator.handleAction(.installedApplicationsViewModelEvent($0))
                    }
                )
            )
            .navigationDestination(for: InstalledApplicationsCoordinator.Destination.self) {
                switch $0 {
                case .folder(let url):
                    DocumentsFolderView(
                        viewModel: .init(
                            folderURL: url,
                            sendEvent: { event in
                                coordinator.handleAction(.documentFolderViewModelEvent(event))
                            }
                        )
                    )
                case .installedApplicationDetails(let details):
                    InstalledApplicationDetailView(
                        viewModel: .init(
                            installedApplication: details,
                            sendEvent: {
                                coordinator.handleAction(.installedApplicationDetailViewEvent($0))
                            }
                        )
                    )
                }
            }
        }
        .nsAlert(item: $coordinator.alert) { alert in
            coordinator.jdAlert(alert)
        }
    }
}
