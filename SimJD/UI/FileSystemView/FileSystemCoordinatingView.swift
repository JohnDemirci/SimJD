//
//  FileSystemCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 12/30/24.
//

import SwiftUI

struct FileSystemCoordinatingView: CoordinatingView {
    enum Action {
        case fileSystemViewEvent(FileSystemView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case fileFetchingError
        case fileFindingError
        case fileOpeningError

        var id: AnyHashable { self }
    }

    @State var alert: Alert?
    @StateObject private var navigator: FileSystemNavigator

    init(initialDestination: FileSystemNavigator.ViewDestination) {
        self._navigator = .init(wrappedValue: .init(initialDestination: initialDestination))
    }

    var body: some View {
        Group {
            switch navigator.last {
            case .fileSystem(url: let url):
                FileSystemView(currentURL: url) {
                    handleAction(.fileSystemViewEvent($0))
                }

            case .installedApplications:
                InstalledApplicationsCoordinatingView()

            case .installedApplicationDetails(let detail):
                InstalledApplicationDetailCoordinatingView(installedApplication: detail)

            case .none:
                EmptyView()
            }
        }
        .nsAlert(item: $alert) { activeAlert in
            return switch activeAlert {
            case .fileFetchingError:
                JDAlert(title: "Could not fetch files")
            case .fileFindingError:
                JDAlert(title: "Could not find the selected files")
            case .fileOpeningError:
                JDAlert(title: "Could not open the selected files")
            }
        }
        .environmentObject(navigator)
        .id(navigator.last)
    }
}

extension FileSystemCoordinatingView {
    func handleAction(_ action: Action) {
        switch action {
        case .fileSystemViewEvent(let event):
            switch event {
            case .didFailToFetchFiles:
                alert = .fileFetchingError
            case .didFailToFindSelectedFile:
                alert = .fileFindingError
            case .didFailToOpenFile:
                alert = .fileOpeningError
            }
        }
    }
}

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
}
