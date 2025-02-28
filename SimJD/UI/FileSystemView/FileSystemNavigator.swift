//
//  FileSystemNavigator.swift
//  SimJD
//
//  Created by John Demirci on 2/28/25.
//

import SwiftUI

@MainActor
final class FileSystemNavigator: ObservableObject {
    enum ViewDestination: Hashable {
        case fileSystem(url: URL)
        case installedApplications
        case installedApplicationDetails(InstalledAppDetail)
    }
    
    private(set) var stack: [ViewDestination]

    init(initialDestination: ViewDestination) {
        self.stack = [initialDestination]
    }

    init() {
        self.stack = []
    }

    var last: ViewDestination? { stack.last }

    func add(_ destination: ViewDestination) {
        stack.append(destination)
        self.objectWillChange.send()
    }

    func pop() {
        stack.removeLast()
        self.objectWillChange.send()
    }

    func resetTo(_ destination: ViewDestination) {
        stack = [destination]
        self.objectWillChange.send()
    }
}
