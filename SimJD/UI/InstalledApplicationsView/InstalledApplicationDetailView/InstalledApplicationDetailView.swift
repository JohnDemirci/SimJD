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
            TableColumn("Action") { (item: InstalledApplicationAction) in
                Text(item.name)
            }
        }
        .contextMenu(
            forSelectionType: InstalledApplicationAction.ID.self,
            menu: { _ in EmptyView() },
            primaryAction: { (selections: Set<InstalledApplicationAction.ID>) in
                viewModel.didSelectAction(selections)
            }
        )
        .scrollContentBackground(.hidden)
    }
}
