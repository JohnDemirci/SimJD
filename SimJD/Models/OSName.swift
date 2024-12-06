//
//  OSName.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation

enum OS {}

extension OS {
    enum Name: Hashable, Comparable, Identifiable, Codable {
        case iOS(String)
        case watchOS(String)
        case tvOS(String)
        case visionOS(String)

        init?(os: String, version: String) {
            if os.localizedStandardContains("watchOS") {
                self = .watchOS(version)
            } else if os.localizedStandardContains("tvOS") {
                self = .tvOS(version)
            } else if os.localizedStandardContains("visionOS") {
                self = .visionOS(version)
            } else if os.localizedStandardContains("iOS") {
                self = .iOS(version)
            } else {
                return nil
            }
        }

        var id: String {
            name
                .lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.iOS(let l), .iOS(let r)):
                return l < r

            case (.iOS, _):
                return true

            case (.watchOS, .iOS):
                return false

            case (.watchOS(let l), .watchOS(let r)):
                return l < r

            case (.watchOS, _):
                return true

            case (.tvOS, .iOS), (.tvOS, .watchOS):
                return false

            case (.tvOS(let l), .tvOS(let r)):
                return l < r

            case (.tvOS, .visionOS):
                return true

            case (.visionOS(let l), .visionOS(let r)):
                return l < r

            case (.visionOS, _):
                return false
            }
        }

        static func > (lhs: Self, rhs: Self) -> Bool {
            !(lhs < rhs)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name
        }

        var order: Int {
            switch self {
            case .iOS:
                return 1
            case .watchOS:
                return 2
            case .tvOS:
                return 3
            case .visionOS:
                return 4
            }
        }

        var name: String {
            switch self {
            case .iOS(let number):
                "iOS \(number)"
            case .watchOS(let number):
                "watchOS \(number)"
            case .tvOS(let number):
                "tvOS \(number)"
            case .visionOS(let number):
                "visionOS \(number)"
            }
        }
    }
}
