//
//  ColorPalette.swift
//  SimJD
//
//  Created by John Demirci on 2/18/25.
//

import SwiftUI

@MainActor
enum ColorPalette {
    case background(ColorScheme)
    case foreground(ColorScheme)

    var color: Color {
        switch self {
        case .background(let scheme):
            switch scheme {
            case .dark:
                return Color.black
            case .light:
                return Color.white
            default:
                return Color.purple
            }

        case .foreground(let scheme):
            switch scheme {
            case .dark:
                return Color.init(nsColor: .systemBrown)
            case .light:
                return Color.init(nsColor: .brown).opacity(0.2)
            default:
                return Color.purple
            }
        }
    }
}
