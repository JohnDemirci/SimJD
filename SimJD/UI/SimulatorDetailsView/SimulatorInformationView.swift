//
//  SimulatorInformationView.swift
//  SimJD
//
//  Created by John Demirci on 12/1/24.
//

import SwiftUI
import AppKit

struct SimulatorInformationView: View {
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

extension SimulatorInformationView {
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

extension SimulatorInformationView.LabeledContentForVStack where C == Text {
    init(title: String, text: String) {
        self.title = title
        self.content = { Text(text) }
    }
}
