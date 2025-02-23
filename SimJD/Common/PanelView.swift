//
//  PanelView.swift
//  SimJD
//
//  Created by John Demirci on 12/29/24.
//

import SwiftUI

struct PanelView<Content: View>: View {
    let title: String
    let columnWidth: CGFloat
    @ViewBuilder let content: () -> Content
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.serif)
                .kerning(0.5)
                .frame(maxWidth: columnWidth)
                .padding(5)
                .foregroundStyle(Color.black)
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12,
                        topTrailingRadius: 12,
                        style: .circular
                    )
                    .fill(
                        ColorPalette.foreground(colorScheme).color
                    )
                )

            content()
                .frame(maxWidth: columnWidth, alignment: .leading)
                .padding(5)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorPalette.background(colorScheme).color)
                .stroke(ColorPalette.foreground(colorScheme).color)
        )
    }
}

struct PanelWithToolbarView<
    Content: View,
    ToolbarView: View
>: View {
    let title: String
    let columnWidth: CGFloat
    @ViewBuilder let content: () -> Content
    @ViewBuilder let toolbar: () -> ToolbarView
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.light)
                .fontDesign(.serif)
                .kerning(0.5)
                .frame(maxWidth: columnWidth)
                .padding(5)
                .foregroundStyle(Color.black)
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12,
                        topTrailingRadius: 12,
                        style: .circular
                    )
                    .fill(
                        ColorPalette.foreground(colorScheme).color
                    )
                )
                .overlay(alignment: .leading) {
                    toolbar()
                }

            content()
                .frame(maxWidth: columnWidth, alignment: .leading)
                .padding(5)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorPalette.background(colorScheme).color)
                .stroke(ColorPalette.foreground(colorScheme).color)
        )
    }
}
