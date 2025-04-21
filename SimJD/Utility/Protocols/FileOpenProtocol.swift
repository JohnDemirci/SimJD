//
//  FileOpenProtocol.swift
//  SimJD
//
//  Created by John Demirci on 4/20/25.
//

import Foundation
import SwiftUI

protocol FileOpenProtocol {
	func open(_ url: URL) -> Result<Void, Failure>
}

struct FileOpener: FileOpenProtocol {
	func open(_ url: URL) -> Result<Void, Failure> {
		if NSWorkspace.shared.open(url) {
			return .success(())
		}

		return .failure(Failure.message("Could not open the file"))
	}
}
