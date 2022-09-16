//
//  StoreReviewPill.swift
//  SnappyV2
//
//  Created by David Bage on 31/05/2022.
//

import SwiftUI

struct StoreReviewPill: View {
    // MARK: - Environment objects
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Constants
    private struct Constants {
        struct NumRatings {
            static let maxPreciseRationgs: Int = 49
        }
        
        struct Main {
            static let spacing: CGFloat = 4
            static let width: CGFloat = 64
            static let height: CGFloat = 24
        }
        
        struct Star {
            static let width: CGFloat = 10
        }
        
        struct Overlay {
            static let cornerRadius: CGFloat = 34
            static let lineWidth: CGFloat = 0.5
        }
    }
    
    // MARK: - Properties
    let container: DIContainer
    let rating: RetailStoreRatings
    
    // MARK: - Computed variables
    private var ratingScore: Double {
        rating.averageRating.round(nearest: 0.5)
    }
    
    private var ratingString: String {
        String(format: Int(exactly: ratingScore) != nil ? "%.0f" : "%.1f", ratingScore)
    }
    
    private var color: Color {
        if ratingScore == 5 {
            return colorPalette.fiveStar
        } else if ratingScore == 2.5 {
            return colorPalette.twoPointFiveStar
        } else if ratingScore == 3 {
            return colorPalette.threeStar
        } else if ratingScore == 3.5 {
            return colorPalette.threePointFiveStar
        } else if ratingScore == 4 {
            return colorPalette.fourStar
        }
        
        return colorPalette.twoStar
    }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    private var numRatings: String {
        if rating.numRatings > Constants.NumRatings.maxPreciseRationgs {
            return Strings.StoreRatings.numRatingsGeneric.localized
        }
        return "(\(rating.numRatings))"
    }
    
    // MARK: - Main view
    var body: some View {
        HStack(spacing: Constants.Main.spacing) {
            Image.Icons.star
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.Star.width)
                .foregroundColor(color)
            
            Text(ratingString)
                .font(.Body2.semiBold())
                .foregroundColor(color)
            
            Text(numRatings)
                .font(.Caption2.semiBold())
                .foregroundColor(colorPalette.typefacePrimary)
        }
        .frame(width: Constants.Main.width, height: Constants.Main.height)
        .background(colorPalette.secondaryWhite)
        .standardPillFormat()
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Overlay.cornerRadius)
                .stroke(.white, lineWidth: Constants.Overlay.lineWidth)
        )
    }
}

#if DEBUG
struct StoreReviewPill_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StoreReviewPill(container: .preview, rating: RetailStoreRatings(averageRating: 2, numRatings: 50))
            
            StoreReviewPill(container: .preview, rating: RetailStoreRatings(averageRating: 2.5, numRatings: 50))
            
            StoreReviewPill(container: .preview, rating: RetailStoreRatings(averageRating: 3, numRatings: 50))
            
            StoreReviewPill(container: .preview, rating: RetailStoreRatings(averageRating: 3.5, numRatings: 50))
            
            StoreReviewPill(container: .preview, rating: RetailStoreRatings(averageRating: 4, numRatings: 50))
            
            StoreReviewPill(container: .preview, rating: RetailStoreRatings(averageRating: 4.5, numRatings: 50))
            
            StoreReviewPill(container: .preview, rating: RetailStoreRatings(averageRating: 5, numRatings: 50))
        }
    }
}
#endif
