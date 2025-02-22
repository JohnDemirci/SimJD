//
//  NavigationSplitViewVisbility.swift
//  SimJD
//
//  Created by John Demirci on 2/22/25.
//

import SwiftUI

extension NavigationSplitViewVisibility: @retroactive RawRepresentable {
	public init?(rawValue: String) {
		if rawValue.caseInsensitiveCompare("all") == .orderedSame {
			self = .all
		} else if rawValue.caseInsensitiveCompare("automatic") == .orderedSame {
			self = .automatic
		} else if rawValue.caseInsensitiveCompare("detailOnly") == .orderedSame {
			self = .detailOnly
		} else if rawValue.caseInsensitiveCompare("doubleColumn") == .orderedSame {
			self = .doubleColumn
		} else {
			return nil
		}
	}

	public var rawValue: String {
		return switch self {
		case .all:
			"all"
		case .automatic:
			"automatic"
		case .detailOnly:
			"detailOnly"
		case .doubleColumn:
			"doubleColumn"
		default:
			fatalError("unknown default")
		}
	}

	public typealias RawValue = String
}
