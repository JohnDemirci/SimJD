//
//  SimulatorDetailsView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SimulatorDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: SimulatorDetailsViewModel

    init(viewModel: SimulatorDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
		GeometryReader { geometry in
			HStack(spacing: 10) {
				leftColumnView
					.frame(width: geometry.size.width * 0.33)
				rightColumnView
					.frame(width: geometry.size.width * 0.66)
			}
            .background(viewModel.getBackgroundColor(scheme: colorScheme))
		}
    }
}

private extension SimulatorDetailsView {
    var leftColumnView: some View {
        ScrollView {
            TabButtonsView(
                selectedTab: $viewModel.selectedTab,
                columnWidth: viewModel.columnWidth
            )
            .padding(10)
            OptionalView(viewModel.selectedSimulator) { simulator in
                SimulatorSettingsView(
                    columnWidth: viewModel.columnWidth,
                    selectedSimulator: simulator,
                    sendEvent: {
                        self.viewModel.handle(action: .actionsViewEvent($0))
                    }
                )
            }
            .padding(10)
            OptionalView(viewModel.selectedSimulator) { simulator in
                SimulatorInformationView(columnWidth: viewModel.columnWidth, simulator: simulator)
            }
            .padding(10)
        }
        .scrollIndicators(.hidden)
    }

    var rightColumnView: some View {
        PanelView(
            title: viewModel.selectedTab.title,
            columnWidth: .infinity,
            content: {
                VStack {
                    switch viewModel.selectedTab {
                    case .activeProcesses:
                        RunningProcessesCoordinatingView()
                    case .documents:
                        DocumentFolderCoordinatingView()
                    case .installedApplications:
                        InstalledApplicationsCoordinatingView()
                    case .geolocation:
                        SimulatorGeolocationCoordinatingView()
                    }
                }
                .id(SimulatorManager.live.selectedSimulator)
            }
        )
        .padding(.vertical, 10)
    }
}

private struct TabButtonsView: View {
    @Binding var selectedTab: SimulatorDetailsViewModel.Tab
    @Environment(\.colorScheme) private var colorScheme

    let columnWidth: CGFloat

    var body: some View {
        PanelView(
            title: "Tab",
            columnWidth: columnWidth,
            content: {
                VStack(alignment: .leading) {
                    ForEach(SimulatorDetailsViewModel.Tab.allCases, id: \.self) { tab in
                        Button(tab.title) {
                            withAnimation(.spring) {
                                selectedTab = tab
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(selectedTab == tab ? colorSelection : Color.clear)
                    }
                }
                .padding()
            }
        )
    }

    private var colorSelection: Color {
        ColorPalette.foreground(colorScheme).color
    }
}

