//
//  SimulatorDetailsView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import Combine
import SwiftUI

struct SimulatorDetailsView: View {
    fileprivate enum Action {
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

    var body: some View {
        HStack(spacing: 10) {
            ScrollView {
                TabButtonsView(selectedTab: $selectedTab, columnWidth: columnWidth)
                OptionalView(simManager.selectedSimulator) { simulator in
                    SimulatorSettingsView(
                        columnWidth: columnWidth,
                        selectedSimulator: simulator,
                        sendEvent: { handleAction(.actionsViewEvent($0)) }
                    )
                }
                OptionalView(simManager.selectedSimulator) { simulator in
                    InformationView(columnWidth: columnWidth, simulator: simulator)
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollIndicators(.hidden)

            VStack {
                PanelWithToolbarView(
                    title: selectedTab.title,
                    columnWidth: .infinity,
                    content: {
                        switch selectedTab {
                        case .activeProcesses:
                            RunningProcessesCoordinatingView()
                        case .documents, .installedApplications:
                            FileSystemCoordinatingView()
                        case .geolocation:
                            SimulatorGeolocationCoordinatingView()
                        }
                    },
                    toolbar: {
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
                )
                .environmentObject(navigator)
                .id(simManager.selectedSimulator)
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .onChange(of: selectedTab) { oldValue, newValue in
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
        colorScheme == .light ? Color.init(nsColor: .brown).opacity(0.2) :
            Color.init(nsColor: .systemBrown)
    }
}

fileprivate struct SimulatorSettingsView: View {
    enum Event {
        case didSelectEraseContentAndSettings(Simulator)
        case didSelectDeleteSimulator(Simulator)
    }

    private let columnWidth: CGFloat
    private let selectedSimulator: Simulator
    private let sendEvent: (Event) -> Void

    init(
        columnWidth: CGFloat,
        selectedSimulator: Simulator,
        sendEvent: @escaping (Event) -> Void
    ) {
        self.columnWidth = columnWidth
        self.selectedSimulator = selectedSimulator
        self.sendEvent = sendEvent
    }

    var body: some View {
        PanelView(
            title: "Settings",
            columnWidth: columnWidth,
            content: {
                VStack(alignment: .leading) {
                    Button("Erase Content and Settings") {
                        sendEvent(.didSelectEraseContentAndSettings(selectedSimulator))
                    }

                    Button("Delete Simulator") {
                        sendEvent(.didSelectDeleteSimulator(selectedSimulator))
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.clear)
                .padding()
            }
        )
    }
}

private struct InformationView: View {
    @Environment(SimulatorManager.self) private var simManager
    let columnWidth: CGFloat
    let simulator: Simulator

    var body: some View {
        PanelView(
            title: "Information",
            columnWidth: columnWidth,
            content: {
                VStack {
                    LabeledContentForVStack(title: "Name", text: simulator.name ?? "")
                    LabeledContentForVStack("ID") {
                        Text(simulator.id)
                            .multilineTextAlignment(.trailing)
                            .textSelection(.enabled)
                    }
                    LabeledContentForVStack("Status") {
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
                    LabeledContentForVStack(title: "Operating System", text: simulator.os?.name ?? "")
                    LabeledContentForVStack("Path") {
                        Text(simulator.dataPath ?? "")
                            .multilineTextAlignment(.trailing)
                            .textSelection(.enabled)
                    }
                    LabeledContentForVStack(title: "Available", text: "\(simulator.isAvailable ?? false)")
                    LabeledContentForVStack("Log Path") {
                        Text(simulator.logPath ?? "")
                            .multilineTextAlignment(.trailing)
                            .textSelection(.enabled)
                    }
                    LabeledContentForVStack(title: "DataPath Size", text: "\(simulator.dataPathSize ?? -1)")

                    OptionalView(simManager.locales[simulator.id]) { locale in
                        LabeledContentForVStack(title: "Locale", text: locale)
                    }
                }
            }
        )
    }
}

extension InformationView {
    struct LabeledContentForVStack<C: View>: View {
        let title: String
        let content: () -> C

        init(_ title: String, content: @escaping () -> C) {
            self.title = title
            self.content = content
        }

        var body: some View {
            HStack(alignment: .top) {
                Text("\(title):")
                Spacer()
                content()
            }
            .padding(7)
        }
    }
}

extension InformationView.LabeledContentForVStack where C == Text {
    init(title: String, text: String) {
        self.title = title
        self.content = { Text(text) }
    }
}
