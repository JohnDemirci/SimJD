//
//  FileSystemCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 12/30/24.
//

import SwiftUI

struct FileSystemCoordinatingView: View {
    @StateObject private var stack: Stack = .init()
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        Group {
            switch stack.urls.last {
            case .some(let url):
                FileSystemView(currentURL: url)
                    .id(url)
                    .environmentObject(stack)
            case .none:
                Text("No url")
            }
        }
        .onAppear {
            stack.add(url)
        }
    }
}

final class Stack: ObservableObject {
    private(set) var urls: [URL] = []

    func add(_ url: URL) {
        urls.append(url)
        self.objectWillChange.send()
    }
}
