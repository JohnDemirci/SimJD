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
                        colorScheme == .light ? Color.init(nsColor: .brown).opacity(0.2) :
                            Color.init(nsColor: .systemBrown)
                    )
                )

            content()
                .frame(maxWidth: columnWidth, alignment: .leading)
                .padding(5)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
            .fill(colorScheme == .light ? Color.white : Color.black)
            .shadow(
                color: colorScheme == .light ? Color.init(nsColor: .brown).opacity(0.2) :
                    Color.init(nsColor: .systemBrown),
                radius: 5,
                x: 1,
                y: 0
            )
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
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12,
                        topTrailingRadius: 12,
                        style: .circular
                    )
                    .fill(
                        colorScheme == .light ? Color.init(nsColor: .brown).opacity(0.2) :
                            Color.init(nsColor: .systemBrown)
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
            .fill(colorScheme == .light ? Color.white : Color.black)
            .shadow(
                color: colorScheme == .light ? Color.init(nsColor: .brown).opacity(0.2) :
                    Color.init(nsColor: .systemBrown),
                radius: 5,
                x: 1,
                y: 0
            )
        )
    }
}
