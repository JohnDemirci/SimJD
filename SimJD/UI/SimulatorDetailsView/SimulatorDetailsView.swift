//
//  SimulatorDetailsView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct SimulatorDetailsView: View {
    enum Action {
        case actionsViewEvent(SimulatorSettingsView.Event)
    }

    enum Event {
        case didSelectEraseContentAndSettings(Simulator)
        case didSelectDeleteSimulator(Simulator)
    }

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

    @Environment(\.colorScheme) private var colorScheme
    @Environment(FolderManager.self) private var folderManager
    @Environment(SimulatorManager.self) private var simManager

    @State private var selectedTab: Tab = .activeProcesses
    @StateObject private var navigator = FileSystemNavigator()

    private let columnWidth: CGFloat = 400
    private let sendEvent: (Event) -> Void

    init(sendEvent: @escaping (Event) -> Void) {
        self.sendEvent = sendEvent
    }

    private var navigatableView: Bool {
        switch selectedTab {
        case .activeProcesses, .geolocation:
            return false
        case .documents, .installedApplications:
            return true
        }
    }

    private var backgroundColor: Color {
        ColorPalette.background(colorScheme).color
    }

    var body: some View {
		GeometryReader { geometry in
			HStack(spacing: 10) {
				leftColumnView
					.frame(width: geometry.size.width * 0.33)
				rightColumnView
					.frame(width: geometry.size.width * 0.66)
			}
			.background(ColorPalette.background(colorScheme).color)
			.onChange(of: selectedTab) { _, newValue in
				switch newValue {
				case .installedApplications:
					withAnimation {
						navigator.resetTo(.installedApplications)
					}
				case .documents:
					guard let selectedSimulator = simManager.selectedSimulator else { return }
					withAnimation {
						navigator.resetTo(.fileSystem(url: URL(fileURLWithPath: selectedSimulator.dataPath ?? "")))
					}
				default:
					break
				}
			}
		}
    }
}

private extension SimulatorDetailsView {
    var leftColumnView: some View {
        ScrollView {
            TabButtonsView(
                selectedTab: $selectedTab,
                columnWidth: columnWidth
            )
            .padding(10)
            OptionalView(simManager.selectedSimulator) { simulator in
                SimulatorSettingsView(
                    columnWidth: columnWidth,
                    selectedSimulator: simulator,
                    sendEvent: { handleAction(.actionsViewEvent($0)) }
                )
            }
            .padding(10)
            OptionalView(simManager.selectedSimulator) { simulator in
                SimulatorInformationView(columnWidth: columnWidth, simulator: simulator)
            }
            .padding(10)
        }
        .scrollIndicators(.hidden)
    }

    var rightColumnView: some View {
        VStack {
            PanelWithToolbarView(
                title: selectedTab.title,
                columnWidth: .infinity,
                content: {
                    Group {
                        switch selectedTab {
                        case .activeProcesses:
                            RunningProcessesCoordinatingView()
                        case .documents, .installedApplications:
                            FileSystemCoordinatingView()
                        case .geolocation:
                            SimulatorGeolocationCoordinatingView()
                        }
                    }
                    .id(simManager.selectedSimulator)
                },
                toolbar: {
                    fileSystemBackButtonView
                }
            )
            .environmentObject(navigator)
        }
        .padding(.vertical, 10)
    }
}

private extension SimulatorDetailsView {
    var fileSystemBackButtonView: some View {
        Button("", systemImage: "chevron.left") {
            withAnimation {
                navigator.pop()
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.black)
        .padding()
        .bold()
        .font(.largeTitle)
        .inCase(!navigatableView || navigator.stack.count < 2) {
            EmptyView()
        }
    }
}

private extension SimulatorDetailsView {
    func handleAction(_ action: Action) {
        switch action {
        case .actionsViewEvent(let event):
            switch event {
            case .didSelectDeleteSimulator(let simulator):
                sendEvent(.didSelectDeleteSimulator(simulator))
            case .didSelectEraseContentAndSettings(let simulator):
                sendEvent(.didSelectEraseContentAndSettings(simulator))
            }
        }
    }
}

private struct TabButtonsView: View {
    @Binding var selectedTab: SimulatorDetailsView.Tab
    @Environment(\.colorScheme) private var colorScheme

    let columnWidth: CGFloat

    var body: some View {
        PanelView(
            title: "Tab",
            columnWidth: columnWidth,
            content: {
                VStack(alignment: .leading) {
                    ForEach(SimulatorDetailsView.Tab.allCases, id: \.self) { tab in
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

