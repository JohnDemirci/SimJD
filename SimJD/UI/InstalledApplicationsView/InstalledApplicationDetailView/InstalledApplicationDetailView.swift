//
//  InstalledApplicationDetailView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct InstalledApplicationDetailView: View {
    @State private var viewModel: InstalledApplicationDetailViewModel

    init(viewModel: InstalledApplicationDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Table(viewModel.actions, selection: $viewModel.selection) {
            TableColumn("Action") { item in
                Text(item.name)
            }
        }
        .contextMenu(
            forSelectionType: InstalledApplicationAction.ID.self,
            menu: {
                switch $0.first {
                case "Info.plist":
                    EmptyView()
                default:
                    EmptyView()
                }
            },
            primaryAction: { selections in
                viewModel.didSelectAction(selections)
            }
        )
        .scrollContentBackground(.hidden)
    }
}
