//
//  DocumentFolderCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 4/14/25.
//

import SwiftUI

struct DocumentFolderCoordinatingView: View {
    @State private var coordinator = DocumentFolderCoordinator()
    @State private var manager = SimulatorManager.live

    var body: some View {
        NavigationStack(path: $coordinator.destination) {
            OptionalView(
                data: manager.selectedSimulator,
                unwrappedData: { selectedSimulator in
                    DocumentsFolderView(
                        viewModel: .init(
                            folderURL: URL(fileURLWithPath: selectedSimulator.dataPath ?? ""),
							copyBoard: CopyBoard(),
                            sendEvent: {
                                coordinator.handleAction(.documentFolderViewEvent($0))
                            }
                        )
                    )
                },
                placeholderView: {
                    Text("No Simulator is selected")
                }
            )
            .navigationDestination(for: DocumentFolderCoordinator.Destination.self) { dest in
                switch dest {
                case .folder(let url):
                    DocumentsFolderView(
                        viewModel: .init(
                            folderURL: url,
							copyBoard: CopyBoard(),
                            sendEvent: {
                                coordinator.handleAction(.documentFolderViewEvent($0))
                            }
                        )
                    )
                }
            }
        }
    }
}
