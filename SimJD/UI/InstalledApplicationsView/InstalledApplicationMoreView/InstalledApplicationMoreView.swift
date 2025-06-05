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
    @State private var selection: FileItem?
    @State private var isExpanded: Bool = false

    init(viewModel: InstalledApplicationMoreViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            Section(
                isExpanded: $isExpanded,
                content: {
                    ForEach(viewModel.fields, id: \.self) { (field: Field) in
                        LabeledContent(field.key, value: field.value)
                    }
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .textSelection(.enabled)
                },
                header: {
                    Button(
                        action: {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        },
                        label: {
                            LabeledContent("Information") {
                                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            }
                        }
                    )
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
            )

            CachedAppBinaryTableView(
                items: $viewModel.fileItems,
                sendEvent: { (event: CachedAppBinaryTableView.Event) in
                    viewModel.handleAction(.cachedAppBinaryTableViewEvent(event))
                }
            )
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
            viewModel.handleViewEvent(.viewDidAppear)
        }
        .toolbar {
            toolbarButtonView()
        }
    }
}

extension InstalledApplicationMoreView {
    func toolbarButtonView() -> some View {
        IfView(viewModel.fields.contains("DerivedData Path")) {
            HStack {
                Button("🚀") {
                    viewModel.handleViewEvent(.didSelectLaunch)
                }
                .help("Launch the app on simulator")

                Button("🔨") {
                    viewModel.handleViewEvent(.didSelectOpenInXcode)
                }
                .help("Open in XCode")

                Button("💾") {
                    viewModel.handleViewEvent(.didSelectCreateCache)
                }
                .help("Cache the current app binary for simulator")
            }
        }
    }
}
