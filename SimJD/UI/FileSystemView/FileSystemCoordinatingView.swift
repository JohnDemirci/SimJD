//
//  FileSystemCoordinatingView.swift
//  SimJD
//
//  Created by John Demirci on 12/30/24.
//

import SwiftUI

@MainActor
@Observable
final class FileSystemCoordinatingViewModel {
    enum Action {
        case fileSystemViewEvent(FileSystemView.Event)
    }

    enum Alert: Hashable, Identifiable {
        case fileFetchingError
        case fileFindingError
        case fileOpeningError

        var id: AnyHashable { self }
    }

    var alert: Alert?

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

struct FileSystemCoordinatingView: CoordinatingView {
    @EnvironmentObject private var navigator: FileSystemNavigator
    @State private var viewModel = FileSystemCoordinatingViewModel()

    var body: some View {
        Group {
            switch navigator.last {
            case .fileSystem(url: let url):
                FileSystemView(currentURL: url) {
                    viewModel.handleAction(.fileSystemViewEvent($0))
                }

            case .installedApplications:
                InstalledApplicationsCoordinatingView()

            case .installedApplicationDetails(let detail):
                InstalledApplicationDetailCoordinatingView(installedApplication: detail)

            case .none:
                EmptyView()
            }
        }
        .nsAlert(item: $viewModel.alert) { activeAlert in
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
