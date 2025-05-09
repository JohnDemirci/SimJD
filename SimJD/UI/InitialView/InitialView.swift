//
//  InitialView.swift
//  SimJD
//
//  Created by John Demirci on 1/10/25.
//

import SwiftUI

struct InitialView: View {
    @AppStorage(Setting.sidebarVisibility.key) private var visibility: NavigationSplitViewVisibility = .doubleColumn
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationSplitView(
            columnVisibility: $visibility,
            sidebar: {
                SidebarView()
                    .navigationSplitViewColumnWidth(300)
            },
            detail: {
                SimulatorDetailsVCoordinatingView()
            }
        )
        .toolbarBackground(
            ColorPalette.background(colorScheme).color,
            for: .windowToolbar
        )
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Image(.logo)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .onAppear {
            addKeyboardShortcut()
        }
    }

    private func addKeyboardShortcut() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.charactersIgnoringModifiers != "e" else {
                toggleSidebar()
                return nil
            }

            return event
        }
    }

    private func toggleSidebar() {
        withAnimation {
            visibility = (visibility == .doubleColumn) ? .detailOnly : .doubleColumn
        }
    }
}
