//
//  SettingsView.swift
//  SimJD
//
//  Created by John Demirci on 2/19/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var tab: SettingsView.ViewTab = .log
    var body: some View {
        TabView(selection: $tab) {
            Tab(
                "Log Settings",
                systemImage: "square.and.pencil",
                value: SettingsView.ViewTab.log
            ) {
                LogSettingsView()
            }

            Tab(
                "Derived Data Path",
                systemImage: "document.circle",
                value: SettingsView.ViewTab.paths
            ) {
                PathsView()
            }
        }
        .scenePadding()
        .frame(maxWidth: 350, minHeight: 100)
    }
}

extension SettingsView {
    enum ViewTab: Hashable {
        case log
        case paths
    }
}
