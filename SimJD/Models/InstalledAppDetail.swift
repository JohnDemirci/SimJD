//
//  InstalledAppDetail.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation

struct InstalledAppDetail: Hashable, Identifiable {
    var applicationType: String?
    var bundle: String?
    var displayName: String?
    var bundleIdentifier: String?
    var bundleName: String?
    var bundleVersion: String?
    var dataContainer: String?
    var path: String?

    var id: String { bundleIdentifier ?? UUID().uuidString }
}
