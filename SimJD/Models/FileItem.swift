//
//  FileItem.swift
//  SimJD
//
//  Created by John Demirci on 12/30/24.
//

import Foundation
import SwiftUI

struct FileItem: Identifiable, Hashable {
    let creationDate: Date?
    let id = UUID()
    let isDirectory: Bool
    let modificationDate: Date?
    let name: String
    let size: Int?
    let contentType: String?
    let url: URL
}
