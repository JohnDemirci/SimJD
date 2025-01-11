//
//  InitialView.swift
//  SimJD
//
//  Created by John Demirci on 1/10/25.
//

import SwiftUI

struct InitialView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn

    var body: some View {
        NavigationSplitView(
            columnVisibility: $visibility,
            sidebar: {
                SidebarView()
                    .navigationSplitViewColumnWidth(300)
            },
            detail: {
                SimulatorDetailsViewCoordinator()
            }
        )
        .toolbarBackground(
            colorScheme == .dark ? Color.black : Color.white,
            for: .windowToolbar
        )
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Image(.logo)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
    }
}
