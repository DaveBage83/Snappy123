//
//  PastOrderLineTab.swift
//  SnappyV2
//
//  Created by David Bage on 20/09/2022.
//

import SwiftUI

struct PastOrderLineTab<Content: View>: View {
    enum TabType {
        case refund
        case substitute
        
        func backgroundColor(colorPalette: ColorPalette) -> Color {
            switch self {
            case .refund:
                return colorPalette.primaryRed
            case .substitute:
                return colorPalette.alertHighlight
            }
        }
        
        var title: String {
            switch self {
            case .refund:
                return Strings.PlacedOrders.OrderDetailsView.removed.localized
            case .substitute:
                return Strings.PlacedOrders.OrderDetailsView.substituted.localized
            }
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    let container: DIContainer
    let tabType: TabType

    @ViewBuilder let content: Content
    
    // MARK: - Constants
    // Unable to use struct here due to injected content in this view
    private let tabHPadding: CGFloat = 8
    private let tabVPadding: CGFloat = 4
    private let tabCornerRadius: CGFloat = 8
    private let lineWidth: CGFloat = 0.5

    private var colorPalette: ColorPalette {
        .init(container: container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(tabType.title)
                    .font(.Body2.semiBold())
                    .padding(.horizontal, tabHPadding)
                    .padding(.vertical, tabVPadding)
                    .background(tabType.backgroundColor(colorPalette: colorPalette))
                    .foregroundColor(.white)
                    .cornerRadius(tabCornerRadius, corners: [.topLeft, .topRight])
                Rectangle()
                    .fill(tabType.backgroundColor(colorPalette: colorPalette))
                    .frame(height: lineWidth)
            }
            
            content
            
            Rectangle()
                .fill(tabType.backgroundColor(colorPalette: colorPalette))
                .frame(height: lineWidth)
        }
    }
}

#if DEBUG
struct PastOrderLineTab_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PastOrderLineTab(container: .preview, tabType: .refund, content: {
                Text("Test content")
            })
            
            PastOrderLineTab(container: .preview, tabType: .substitute, content: {
                Text("Test content")
            })
        }
    }
}
#endif
