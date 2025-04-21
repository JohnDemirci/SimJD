//
//  InstalledApplicationsView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct InstalledApplicationsView: View {
    @State private var viewModel: InstalledApplicationsViewModel

    init(viewModel: InstalledApplicationsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        OptionalView(
            data: viewModel.installedApplications,
            unwrappedData: { installedApps in
                Table(installedApps, selection: $viewModel.selectedApp) {
                    TableColumn("Name") { item in
                        HStack {
                            Text(item.displayName ?? "")
                        }
                    }

                    TableColumn("Bundle ID") { item in
                        Text(item.bundleIdentifier ?? "")
                    }

                    TableColumn("Type") { item in
                        Text(item.applicationType ?? "")
                    }

                    TableColumn("Path") { item in
                        Text(item.path ?? "")
                    }
                }
            },
            placeholderView: {
                Text("nothing")
            }
        )
        .viewDidLoad {
            viewModel.fetchAndObserve()
        }
        .contextMenu(
            forSelectionType: InstalledAppDetail.ID.self,
            menu: { selections in
                Button("Copy Bundle Identifier") {
                    viewModel.didSelectCopyBundleID(selections)
                }

                Button("Copy Data Container Path") {
                    viewModel.didSelectCopyDataContainerPath(selections)
                }

                Button("Copy Application Path") {
                    viewModel.didSelectCopyApplicationPath(selections)
                }

                Button("Copy Bundle Path") {
                    viewModel.didSelectCopyBundlePath(selections)
                }
            },
            primaryAction: { selectedItems in
                viewModel.didSelectApp(selectedItems)
            }
        )
        .scrollContentBackground(.hidden)
    }
}
