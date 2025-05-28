//
//  PathsView.swift
//  SimJD
//
//  Created by John Demirci on 5/19/25.
//

import SwiftUI
import AppKit

struct PathsView: View {
    @AppStorage(Setting.derivedDataPath.key) private var url: URL = .defaultDerivedDataURL

    var body: some View {
        VStack(spacing: 16) {
            Text(url.absoluteString.removingPercentEncoding ?? "")
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .textSelection(.enabled)

            Button("Select Folder") {
                let panel = NSOpenPanel()
                panel.canChooseDirectories = true
                panel.directoryURL = self.url
                panel.canChooseFiles = false
                panel.showsHiddenFiles = true
                panel.allowsMultipleSelection = false

                if panel.runModal() == .OK {
                    if let unwrappedPanel = panel.url {
                        self.url = unwrappedPanel
                    }
                }
            }
        }
    }
}
