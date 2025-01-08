//
//  SimulatorDetailsView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import Combine
import SwiftUI

struct SimulatorDetailsView: View {
    enum Tab: Hashable, CaseIterable {
        case activeProcesses
        case documents
        case eraseContentAndSettings
        case geolocation
        case installedApplications

        var title: String {
            switch self {
            case .activeProcesses:          return "Active Processes"
            case .documents:                return "Documents"
            case .eraseContentAndSettings:  return "Erase Content & Settings"
            case .geolocation:              return "Geolocation"
            case .installedApplications:    return "Installed Applications"
            }
        }
    }

    @Environment(FolderManager.self) private var folderManager
    @Environment(SimulatorManager.self) private var simManager

    @State private var selectedTab: Tab = .activeProcesses

    @Environment(\.colorScheme) private var colorScheme

    private let columnWidth: CGFloat = 400

    var body: some View {
        HStack(spacing: 10) {
            VStack {
                ActionsView(selectedTab: $selectedTab, columnWidth: columnWidth)
                OptionalView(simManager.selectedSimulator) { simulator in
                    InformationView(columnWidth: columnWidth, simulator: simulator, simManager: simManager)
                }
            }

            VStack {
                PanelView(
                    title: selectedTab.title,
                    columnWidth: .infinity,
                    content: {
                        switch selectedTab {
                        case .activeProcesses:
                            RunningProcessesCoordinatingView()
                        case .documents:
                            FileSystemCoordinatingView(
                                initialDestination: .fileSystem(
                                    url: URL(
                                        fileURLWithPath: simManager.selectedSimulator?.dataPath ?? ""
                                    )
                                )
                            )
                        case .eraseContentAndSettings:
                            EmptyView()
                        case .geolocation:
                            SimulatorGeolocationCoordinatingView(simManager: simManager)
                        case .installedApplications:
                            FileSystemCoordinatingView(initialDestination: .installedApplications)
                        }
                    }
                )
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}



private struct ActionsView: View {
    @Binding var selectedTab: SimulatorDetailsView.Tab
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
                        .background(
                            selectedTab == tab ? Color.red : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        )
    }
}

private struct InformationView: View {
    let columnWidth: CGFloat
    let simulator: Simulator
    @Bindable var simManager: SimulatorManager

    @State private var deviceNameDisclosureGroupExpanded = true
    @State private var identifierDisclosrueGroupExpanded = true
    @State private var statusDisclosureGroupExpanded = true
    @State private var operatingSystemDisclosureGroupExpanded = true

    var body: some View {
        PanelView(
            title: "Information",
            columnWidth: columnWidth,
            content: {
                List {
                    Group {
                        LabeledContent("Name", value: simulator.name ?? "")
                        LabeledContent("ID", value: simulator.id)
                            .textSelection(.enabled)
                        LabeledContent("Status") {
                            Toggle(
                                isOn: Binding(
                                    get: { simulator.state == "Booted" },
                                    set: { newVal in
                                        if newVal {
                                            simManager.openSimulator(simulator)
                                        } else {
                                            simManager.shutdownSimulator(simulator)
                                        }
                                    }
                                ),
                                label: {
                                    EmptyView()
                                }
                            )
                            .toggleStyle(.switch)
                        }
                        LabeledContent("OS", value: simulator.os?.name ?? "")
                        LabeledContent("Path", value: simulator.dataPath ?? "")
                            .multilineTextAlignment(.trailing)
                            .textSelection(.enabled)
                        LabeledContent("is Available", value: "\(simulator.isAvailable ?? false)")
                        LabeledContent("Log Path", value: simulator.logPath ?? "")
                        LabeledContent("DataPath Size", value: "\(simulator.dataPathSize ?? -1)")
                    }
                    .listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
            }
        )
    }
}
