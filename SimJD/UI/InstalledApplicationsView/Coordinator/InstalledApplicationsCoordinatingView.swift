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
                viewModel: InstalledApplicationsViewModel(
                    sendEvent: { (event: InstalledApplicationsViewModel.Event) in
                        coordinator.handleAction(.installedApplicationsViewModelEvent(event))
                    }
                )
            )
            .navigationDestination(for: InstalledApplicationsCoordinator.Destination.self) {
                switch $0 {
                case .cachedBuildDetailsView(let fileItem, let installedAppDetail):
                    CachedBuildDetailsView(
                        viewModel: CachedBuildDetailsViewModel(
                            details: installedAppDetail,
                            fileItem: fileItem,
                            sendEvent: { (event: CachedBuildDetailsViewModel.Event) in
                                coordinator.handleAction(.cachedBuildDetailsViewModelEvent(event))
                            }
                        )
                    )
                case .folder(let url):
                    DocumentsFolderView(
                        viewModel: DocumentsFolderViewModel(
                            folderURL: url,
							copyBoard: CopyBoard(),
                            sendEvent: { (event: DocumentsFolderViewModel.Event) in
                                coordinator.handleAction(.documentFolderViewModelEvent(event))
                            }
                        )
                    )
                case .installedApplicationDetails(let details):
                    InstalledApplicationDetailView(
                        viewModel: InstalledApplicationDetailViewModel(
                            installedApplication: details,
                            sendEvent: { (event: InstalledApplicationDetailViewModel.Event) in
                                coordinator.handleAction(.installedApplicationDetailViewEvent(event))
                            }
                        )
                    )
                case .installedApplicationMore(let details):
                    BuildsAndCachesView(
                        viewModel: BuildsAndCachesViewModel(
                            detail: details,
                            sendEvent: { (event: BuildsAndCachesViewModel.Event) in
                                coordinator.handleAction(.buildsAndCachesViewModelEvent(event))
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
