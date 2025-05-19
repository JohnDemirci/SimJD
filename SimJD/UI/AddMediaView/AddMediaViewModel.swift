//
//  AddMediaViewModel.swift
//  SimJD
//
//  Created by John Demirci on 5/14/25.
//

import SwiftUI

@MainActor
@Observable
final class AddMediaViewModel {
    private let manager: SimulatorManager
    private let simulator: Simulator

    var isTargeted: Bool = false

    var addedMedia: [String] = []
    var failedToAddMedia: [String] = []

    init(
        manager: SimulatorManager,
        simulator: Simulator
    ) {
        self.manager = manager
        self.simulator = simulator
    }

    func handleDrop(_ providers: sending [NSItemProvider]) async -> Bool {
        return await withTaskGroup(of: String?.self) { group in
            for provider in providers {
                // Skip providers that don’t conform
                guard provider.hasItemConformingToTypeIdentifier("public.file-url") else { continue }

                group.addTask {
                    // NSSecureCoding is not Sendable, so loadItem must be handled cautiously
                    guard let item = try? await provider.loadItem(forTypeIdentifier: "public.file-url") else {
                        return nil
                    }

                    // Try casting safely
                    if let data = item as? Data,
                       let url = NSURL(absoluteURLWithDataRepresentation: data, relativeTo: nil) as URL? {
                        return url.path
                    } else if let url = item as? URL {
                        return url.path
                    }

                    return nil
                }
            }

            var atLeastOneSuccess = false

            for await path in group {
                if let path {
                    atLeastOneSuccess = true
                    self.addImageToSimulator(atPath: path)
                }
            }

            return atLeastOneSuccess
        }
    }

    func addImageToSimulator(atPath: String) {
        switch manager.addMedia(id: simulator.id, path: atPath) {
        case .success:
            addedMedia.append(atPath)
        case .failure:
            failedToAddMedia.append(atPath)
        }
    }

    func listHeight() -> CGFloat {
        let addedMediaHeight: CGFloat = 5 * CGFloat(addedMedia.count)
        let failedToAddMediaHeight: CGFloat = 5 * CGFloat(failedToAddMedia.count)
        let headerHeight: CGFloat = 100

        return headerHeight + addedMediaHeight + failedToAddMediaHeight
    }
}

extension NSItemProvider: @unchecked @retroactive Sendable {}
