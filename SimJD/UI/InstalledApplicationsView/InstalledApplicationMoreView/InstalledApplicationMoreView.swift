//
//  InstalledApplicationMoreView.swift
//  SimJD
//
//  Created by John Demirci on 5/19/25.
//

import SwiftUI

struct InstalledApplicationMoreView: View {
    @State private var viewModel: InstalledxApplicationMoreViewModel

    init(viewModel: InstalledxApplicationMoreViewModel) {
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
                            viewModel.didSelectLaunch()
                        }

                        Button("Open in Xcode") {
                            viewModel.didSelectOpenInXcode()
                        }
                    }
                },
                falseView: {
                    Text("No path to derived data found. Please rebuild the app through xcode and try again")
                }
            )
        }
        .onAppear {
            viewModel.generateFields()
        }
    }
}
