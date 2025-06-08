//
//  CachedBuildDetailsView.swift
//  SimJD
//
//  Created by John Demirci on 6/5/25.
//

import SwiftUI

struct CachedBuildDetailsView: View {
    enum Event {
        case didLoadView
        case didSelectLaunchInSimulator
    }

    @Bindable var viewModel: CachedBuildDetailsViewModel

    init(viewModel: CachedBuildDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            OptionalView(viewModel.items) { items in
                ForEach(items.array, id: \.0) { item in
                    LabeledContent(item.0, value: item.1)
                }
            }

            Button("Launch in Simulator") {
                viewModel.handleViewEvent(.didSelectLaunchInSimulator)
            }
        }
        .viewDidLoad {
            viewModel.handleViewEvent(.didLoadView)
        }
    }
}

extension Dictionary {
    var array: [(Key, Value)] {
        map {
            ($0.key, $0.value)
        }
    }
}
