//
//  CopyBoardProtocol.swift
//  SimJD
//
//  Created by John Demirci on 4/15/25.
//

import Foundation
import SwiftUI

protocol CopyBoardProtocol {
    func clear()
    func copy(_ text: String)
}

struct CopyBoard: CopyBoardProtocol {
    private let board: NSPasteboard

    init() {
        self.board = .general
    }

    func clear() {
        board.clearContents()
    }

    func copy(_ text: String) {
        board.setString(text, forType: .string)
    }
}
