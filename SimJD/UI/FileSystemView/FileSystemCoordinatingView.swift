//
//  FileSystemCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 12/30/24.
//

import SwiftUI

struct FileSystemCoordinatingView: CoordinatingView {
    private let navigator = FileSystemNavigator.shared
    @State private var viewModel = FileSystemCoordinatingViewModel()

    var body: some View {
        Group {
            switch navigator.last {
            case .fileSystem(url: let url):
                FileSystemView(currentURL: url) {
                    viewModel.handleAction(.fileSystemViewEvent($0))
                }

            case .installedApplications:
                InstalledApplicationsCoordinatingView()

            case .installedApplicationDetails(let detail):
                InstalledApplicationDetailCoordinatingView(installedApplication: detail)

            case .none:
                EmptyView()
            }
        }
        .nsAlert(item: $viewModel.alert) { activeAlert in
            return switch activeAlert {
            case .fileFetchingError:
                JDAlert(title: "Could not fetch files")
            case .fileFindingError:
                JDAlert(title: "Could not find the selected files")
            case .fileOpeningError:
                JDAlert(title: "Could not open the selected files")
            }
        }
        .environmentObject(navigator)
        .id(navigator.last)
    }
}
