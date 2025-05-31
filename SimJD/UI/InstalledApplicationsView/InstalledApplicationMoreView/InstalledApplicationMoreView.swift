//
//  InstalledApplicationMoreView.swift
//  SimJD
//
//  Created by John Demirci on 5/19/25.
//

import SwiftUI

struct InstalledApplicationMoreView: View {
    enum Event {
        case didSelectCreateCache
        case didSelectLaunch
        case didSelectOpenInXcode
        case viewDidAppear
    }

    @State private var viewModel: InstalledApplicationMoreViewModel

    init(viewModel: InstalledApplicationMoreViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            Section {
                ForEach(viewModel.fields, id: \.self) { (field: Field) in
                    LabeledContent(field.key, value: field.value)
                }
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .textSelection(.enabled)
            }

            IfView(
                viewModel.fields.contains("DerivedData Path"),
                trueView: {
                    Section {
                        Button("Launch") {
                            viewModel.handleViewEvent(.didSelectLaunch)
                        }

                        Button("Open in Xcode") {
                            viewModel.handleViewEvent(.didSelectOpenInXcode)
                        }

                        Button("Cache Current App Binary For Simulator") {
                            viewModel.handleViewEvent(.didSelectCreateCache)
                        }
                    }
                },
                falseView: {
                    Text("No path to derived data found. Please rebuild the app through xcode and try again")
                }
            )
        }
        .onAppear {
            viewModel.handleViewEvent(.viewDidAppear)
        }
    }
}
