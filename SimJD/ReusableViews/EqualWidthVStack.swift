//
//  EqualWidthVStack.swift
//  SimJD
//
//  Created by John Demirci on 12/29/24.
//

import SwiftUI

struct EqualWidthVStack: Layout {
    /// Returns a size that the layout container needs to arrange its subviews
    /// vertically with equal widths.
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        // Load size and spacing information from the cache.
        let maxSize = cache.maxSize
        let totalSpacing = cache.totalSpacing

        return CGSize(
            width: maxSize.width,
            height: maxSize.height * CGFloat(subviews.count) + totalSpacing)
    }

    /// Places the subviews in a vertical stack.
    /// - Tag: placeSubviewsVertical
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) {
        guard !subviews.isEmpty else { return }

        // Load size and spacing information from the cache.
        let maxSize = cache.maxSize
        let spacing = cache.spacing

        let placementProposal = ProposedViewSize(width: maxSize.width, height: bounds.height)
        var nextY = bounds.minY + maxSize.height / 2

        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: bounds.midX, y: nextY),
                anchor: .center,
                proposal: placementProposal)
            nextY += maxSize.height + spacing[index]
        }
    }

    /// A type that stores cached data.
    /// - Tag: CacheData
    struct CacheData {
        let maxSize: CGSize
        let spacing: [CGFloat]
        let totalSpacing: CGFloat
    }

    /// Creates a cache for a given set of subviews.
    ///
    /// When the subviews change, SwiftUI calls the ``updateCache(_:subviews:)``
    /// method. The ``MyEqualWidthVStack`` layout relies on the default
    /// implementation of that method, which just calls this method again
    /// to recreate the cache.
    /// - Tag: makeCache
    func makeCache(subviews: Subviews) -> CacheData {
        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }

        return CacheData(
            maxSize: maxSize,
            spacing: spacing,
            totalSpacing: totalSpacing)
    }

    /// Finds the largest ideal size of the subviews.
    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(
                width: max(currentMax.width, subviewSize.width),
                height: max(currentMax.height, subviewSize.height))
        }

        return maxSize
    }

    /// Gets an array of preferred spacing sizes between subviews in the
    /// vertical dimension.
    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }

            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .vertical)
        }
    }
}
