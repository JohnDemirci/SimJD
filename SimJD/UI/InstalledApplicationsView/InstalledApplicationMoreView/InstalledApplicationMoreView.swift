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

            OptionalView(viewModel.fileItems) { (fileItems: [FileItem]) in
                Section {
                    Table(fileItems) {
                        TableColumn("Name") { (item: FileItem) in
                            HStack {
                                FileIconView(url: item.url)
                                Text(item.name)
                            }
                        }

                        TableColumn("Creation Date") { (item: FileItem) in
                            Text("\(item.creationDate?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
                        }

                        TableColumn("Last Modified") { (item: FileItem) in
                            Text("\(item.modificationDate?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
                        }

                        TableColumn("Type") { (item: FileItem) in
                            Text(item.contentType ?? "N/A")
                        }

                        TableColumn("Size") { (item: FileItem) in
                            if let size = item.size {
                                Text(size, format: .number)
                            } else {
                                Text("N/A")
                            }
                        }
                    }
                    .contextMenu(
                        forSelectionType: FileItem.ID.self,
                        menu: { _ in EmptyView() },
                        primaryAction: { (selectedIDs: Set<FileItem.ID>) in
                            viewModel.didSelectCachedFolder(selectedIDs)
                        }
                    )
                    .scrollDisabled(true)
                    .frame(height: CGFloat(fileItems.count) * 50 + 50)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
            viewModel.handleViewEvent(.viewDidAppear)
        }
        .toolbar {
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
}

private struct ConditionalToolbarViewModifier<V: View>: ViewModifier {
    private let condition: Bool
    @ViewBuilder private var content: () -> V

    init(
        _ condition: Bool,
        @ViewBuilder view: @escaping () -> V
    ) {
        self.condition = condition
        self.content = view
    }

    func body(content: Content) -> some View {
        if condition {
            content
                .toolbar {
                    self.content()
                }
        }
    }
}

extension View {
    func conditionalToolbar<V: View>(
        _ condition: Bool,
        @ViewBuilder view: @escaping () -> V
    ) -> some View {
        modifier(ConditionalToolbarViewModifier(condition, view: view))
    }
}
