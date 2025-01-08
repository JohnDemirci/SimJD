//
//  FileSystemCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 12/30/24.
//

import SwiftUI

struct FileSystemCoordinatingView: View {
    @StateObject private var navigator: FileSystemNavigator

    init(initialDestination: FileSystemNavigator.ViewDestination) {
        self._navigator = .init(wrappedValue: .init(initialDestination: initialDestination))
    }

    var body: some View {
        Group {
            switch navigator.last {
            case .fileSystem(url: let url):
                FileSystemView(currentURL: url)
                
            case .installedApplications:
                InstalledApplicationsCoordinatingView()

            case .installedApplicationDetails(let detail):
                InstalledApplicationDetailCoordinatingView(installedApplication: detail)

            case .none:
                EmptyView()
            }
        }
        .environmentObject(navigator)
        .id(navigator.last)
    }
}

final class FileSystemNavigator: ObservableObject {
    enum ViewDestination: Hashable {
        case fileSystem(url: URL)
        case installedApplications
        case installedApplicationDetails(InstalledAppDetail)
    }
    
    private(set) var stack: [ViewDestination] = []

    init(initialDestination: ViewDestination) {
        self.stack = [initialDestination]
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
}
