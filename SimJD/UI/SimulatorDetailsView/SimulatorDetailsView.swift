//
//  SimulatorDetailsView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import Combine
import SwiftUI

struct SimulatorDetailsView: View {
    enum Action {
        case deviceStatusViewEvent(DeviceStatusView.Event)
        case simulatorActionOptionsViewEvent(SimulatorActionOptionsView.Event)
    }

    enum Event {
        case didFailToEraseContents(Simulator)
        case didFailToOpenFolder(Failure)
        case didSelectDeleteSimulator(Simulator)
        case didSelectEraseData(Simulator)
        case didSelectGeolocation(Simulator)
        case didSelectInstalledApplications
        case didSelectRunningProcesses
    }

    enum Tab: Hashable, CaseIterable {
        case activeProcesses
        case documents
        case eraseContentAndSettings
        case geolocation
        case installedApplications

        var title: String {
            switch self {
            case .activeProcesses: return "Active Processes"
            case .documents: return "Documents"
            case .eraseContentAndSettings: return "Erase Content & Settings"
            case .geolocation: return "Geolocation"
            case .installedApplications: return "Installed Applications"
            }
        }
    }

    @Bindable private var simManager: SimulatorManager
    @Bindable private var folderManager: FolderManager

    @State private var selectedTab: Tab = .activeProcesses

    @Environment(\.colorScheme) private var colorScheme

    private let columnWidth: CGFloat = 400
    private let sendEvent: (Event) -> Void

    init(
        folderManager: FolderManager,
        simManager: SimulatorManager,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.simManager = simManager
        self.folderManager = folderManager
        self.sendEvent = sendEvent
    }

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
                            RunningProcessesCoordinatingView(simManager: simManager)
                        case .documents:
                            FileSystemCoordinatingView(
                                url: URL(
                                    fileURLWithPath: simManager.selectedSimulator?.dataPath ?? ""
                                )
                            )
                        case .eraseContentAndSettings:
                            EmptyView()
                        case .geolocation:
                            SimulatorGeolocationCoordinatingView(simManager: simManager)
                        case .installedApplications:
                            InstalledApplicationsCoordinatingView(
                                folderManager: folderManager,
                                simulatorManager: simManager
                            )
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

extension SimulatorDetailsView {
    func oldView() -> some View {
        HStack {
            DeviceStatusView(simManager: simManager) {
                handleAction(.deviceStatusViewEvent($0))
            }

            VStack {
                SimulatorInformationView(simManager: simManager)
                SimulatorActionOptionsView(
                    folderManager: folderManager,
                    simManager: simManager,
                    sendEvent: {
                        handleAction(.simulatorActionOptionsViewEvent($0))
                    }
                )
                Spacer()
            }
            .textSelection(.enabled)
            .padding()
        }
    }
}

extension SimulatorDetailsView {
    func handleAction(_ action: Action) {
        switch action {
        case .deviceStatusViewEvent(let event):
            handleDeviceStatusEvent(event)

        case .simulatorActionOptionsViewEvent(let event):
            handleSimulatorActionOptionsViewEvent(event)
        }
    }
}

private extension SimulatorDetailsView {
    func handleDeviceStatusEvent(_ event: DeviceStatusView.Event) {
        switch event {
        case .didSelectDeleteSimulator(let simulator):
            sendEvent(.didSelectDeleteSimulator(simulator))
        }
    }

    func handleSimulatorActionOptionsViewEvent(_ event: SimulatorActionOptionsView.Event) {
        switch event {
        case .didFailToOpenFolder(let error):
            sendEvent(.didFailToOpenFolder(error))

        case .didSelectEraseData(let simulator):
            sendEvent(.didSelectEraseData(simulator))

        case .didSelectGeolocation(let simulator):
            sendEvent(.didSelectGeolocation(simulator))

        case .didSelectInstalledApplications:
            sendEvent(.didSelectInstalledApplications)

        case .didSelectRunningProcesses:
            sendEvent(.didSelectRunningProcesses)
        }
    }
}
