//
//  InstalledAppDetail.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation

@dynamicMemberLookup
struct InstalledAppDetail: Hashable, Identifiable {
    var applicationType: String?
    var bundle: String?
    var bundleIdentifier: String?
    var bundleName: String?
    var bundleVersion: String?
    var dataContainer: String?
    var displayName: String?
    var path: String?

    subscript (dynamicMember keyPath: String) -> String? {
        get {
            dictionaryRepresentation[keyPath]
        }
    }

    var id: String { bundleIdentifier ?? UUID().uuidString }

    var dictionaryRepresentation: [String: String] {
        [
            "applicationType": applicationType ?? "N/A",
            "bundle": bundle ?? "N/A",
            "bundleIdentifier": bundleIdentifier ?? "N/A",
            "bundleName": bundleName ?? "N/A",
            "bundleVersion": bundleVersion ?? "N/A",
            "dataContainer": dataContainer ?? "N/A",
            "displayName": displayName ?? "N/A",
            "path": path ?? "N/A"
        ]
    }
}
