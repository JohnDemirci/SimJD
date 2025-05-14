//
//  FileItem.swift
//  SimJD
//
//  Created by John Demirci on 12/30/24.
//

import Foundation

struct FileItem: Identifiable, Hashable {
    let creationDate: Date?
    let id = UUID()
    let isDirectory: Bool
    let modificationDate: Date?
    let name: String
    let size: Int?
    let url: URL
}
