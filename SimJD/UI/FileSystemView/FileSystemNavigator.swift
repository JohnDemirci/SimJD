//
//  FileSystemNavigator.swift
//  SimJD
//
//  Created by John Demirci on 2/28/25.
//

import SwiftUI

@MainActor
@Observable
final class FileSystemNavigator: ObservableObject {
    enum ViewDestination: Hashable {
        case fileSystem(url: URL)
        case installedApplications
        case installedApplicationDetails(InstalledAppDetail)
    }
    
    private(set) var stack: [ViewDestination]

    private init() {
        self.stack = []
    }

    static let shared = FileSystemNavigator()

    var last: ViewDestination? { stack.last }

    func add(_ destination: ViewDestination) {
        stack.append(destination)
    }

    func pop() {
        stack.removeLast()
    }

    func resetTo(_ destination: ViewDestination) {
        stack = [destination]
    }
}
