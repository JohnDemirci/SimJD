//
//  Device.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation

enum Device: Codable, Hashable, Equatable {
    case appleWatch
    case ipad(iPad)
    case iphone(iPhone)
    case tv
    case vision

    init?(key: String) {
        if key.localizedStandardContains("iphone") {
            self = .iphone(.init(key))
        } else if key.localizedStandardContains("watch") {
            self = .appleWatch
        } else if key.localizedStandardContains("tv") {
            self = .tv
        } else if key.localizedStandardContains("vision") {
            self = .vision
        } else if key.localizedStandardContains("ipad") {
            self = .ipad(.init())
        } else {
            return nil
        }
    }

    var systemImage: String {
        switch self {
        case .appleWatch:
            "applewatch"
        case .ipad(let ipad):
            ipad.systemImage
        case .iphone(let iphoneGen):
            iphoneGen.systemImage
        case .tv:
            "appletv"
        case .vision:
            "vision.pro"
        }
    }
}

extension Device {
    enum iPhone: Codable, Hashable, Equatable {
        case gen1
        case gen2
        case gen3

        init(_ key: String) {
            let plus14 = key.localizedStandardContains("14-plus")

            if plus14 {
                self = .gen2
            }

            let gen3 = key.localizedStandardContains("14") || key.localizedStandardContains("15") || key.localizedStandardContains("16")

            if gen3 {
                self = .gen3
                return
            }

            let gen2 = key.localizedStandardContains("13") || key.localizedStandardContains("12") || key.localizedStandardContains("11") ||
                key.localizedStandardContains("X")

            if gen2 {
                self = .gen2
            }

            self = .gen1
        }

        var systemImage: String {
            switch self {
            case .gen1:
                "iphone.gen1"
            case .gen2:
                "iphone.gen2"
            case .gen3:
                "iphone.gen3"
            }
        }
    }

    enum iPad: Codable, Hashable, Equatable {
        case gen1
        case gen2

        init() {
            self = .gen2
        }

        var systemImage: String {
            switch self {
            case .gen1:
                "ipad.gen1"
            case .gen2:
                "ipad.gen2"
            }
        }
    }
}
