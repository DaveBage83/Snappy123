//
//  OrderStatusPill.swift
//  SnappyV2
//
//  Created by David Bage on 13/05/2022.
//

import SwiftUI

struct OrderStatusPill: View {
    @ScaledMetric var scale: CGFloat = 1 // Used to scale icon for accessibility options
    @Environment(\.colorScheme) var colorScheme
    
    enum PillType {
        case pill
        case text
    }
    
    enum Size {
        case large
        case small
        
        var font: Font {
            switch self {
            case .large:
                return .Caption1.semiBold()
            case .small:
                return .Caption2.semiBold()
            }
        }
        
        var height: CGFloat {
            switch self {
            case .large:
                return 18
            case .small:
                return 16
            }
        }
        
        var hPadding: CGFloat {
            switch self {
            case .large:
                return 8
            case .small:
                return 12
            }
        }
    }
    
    var highlightColor: Color {
        switch status {
        case .standard:
            switch type {
            case .pill:
                return colorPalette.primaryBlue
            case .text:
                return colorPalette.textGrey1
            }
        case .success:
            return colorPalette.alertSuccess
        case .error:
            return colorPalette.alertWarning
        }
    }
    
    var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    var backgroundColor: Color {
        switch type {
        case .pill:
            return highlightColor
        case .text:
            return Color.clear
        }
    }
    
    var textColor: Color {
        switch type {
        case .pill:
            return colorPalette.typefaceInvert
        case .text:
            return highlightColor
        }
    }
    
    let container: DIContainer
    let title: String
    let status: OrderStatus.StatusType
    let size: Size
    let type: PillType
    
    var body: some View {
        Text(title)
            .font(size.font)
            .frame(height: size.height * scale)
            .padding(.horizontal, type == .pill ? size.hPadding * scale : 0)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .standardPillCornerRadius()
    }
}

#if DEBUG
struct OrderStatusPill_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OrderStatusPill(container: .preview, title: "Sent to store", status: .standard, size: .large, type: .pill)
            
            OrderStatusPill(container: .preview, title: "Sent to store", status: .success, size: .large, type: .pill)
            
            OrderStatusPill(container: .preview, title: "Sent to store", status: .error, size: .large, type: .pill)
            
            OrderStatusPill(container: .preview, title: "Sent to store", status: .standard, size: .large, type: .text)
            
            OrderStatusPill(container: .preview, title: "Sent to store", status: .success, size: .large, type: .text)
            
            OrderStatusPill(container: .preview, title: "Sent to store", status: .error, size: .large, type: .text)
        }
    }
}
#endif
