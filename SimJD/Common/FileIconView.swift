//
//  FileIconView.swift
//  SimJD
//
//  Created by John Demirci on 12/30/24.
//

import SwiftUI
import AppKit

struct FileIconView: View {
    let url: URL

    var body: some View {
        Image(nsImage: NSWorkspace.shared.icon(forFile: url.path) )
    }
}
