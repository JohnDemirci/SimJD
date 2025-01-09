//
//  FileItem.swift
//  SimJD
//
//  Created by John Demirci on 12/30/24.
//

import Foundation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: URL
    let isDirectory: Bool
    let creationDate: Date?
    let modificationDate: Date?
    let size: Int?
}
