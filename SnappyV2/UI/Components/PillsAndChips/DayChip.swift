//
//  DayChip.swift
//  SnappyV2
//
//  Created by David Bage on 12/05/2022.
//

import SwiftUI

struct DayChip: View {
    @Environment(\.colorScheme) var colorScheme
    
    enum Size {
        case small
        case large
        
        var font: Font {
            switch self {
            case .small:
                return .Caption1.semiBold()
            case .large:
                return .Body2.semiBold()
            }
        }
        
        var hPadding: CGFloat {
            switch self {
            case .small:
                return 12
            case .large:
                return 16
            }
        }
    }
    
    enum ChipType {
        case chip
        case text
        
        var vPadding: CGFloat {
            switch self {
            case .chip:
                return 4
            case .text:
                return 0
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .chip:
                return 24
            case .text:
                return 0
            }
        }
    }
    
    enum ChipScheme {
        case primary
        case secondary
    }
    
    var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    var disabledBackgroundColor: Color {
        switch type {
        case .chip:
            return colorPalette.textGrey3
        case .text:
            return .clear
        }
    }
    
    let container: DIContainer
    let title: String
    let type: ChipType
    let scheme: ChipScheme
    let size: Size
    let disabled: Bool
    
    init(container: DIContainer, title: String, type: ChipType, scheme: ChipScheme, size: Size, disabled: Bool = false) {
        self.container = container
        self.title = title
        self.type = type
        self.scheme = scheme
        self.size = size
        self.disabled = disabled
    }
    
    var body: some View {
        Text(title)
            .font(size.font)
            .padding(.horizontal, type == .chip ? size.hPadding : 0)
            .padding(.vertical, type.vPadding)
            .background(disabled ? disabledBackgroundColor : scheme == .secondary && type == .chip ? colorPalette.primaryBlue : colorPalette.secondaryWhite)
            .foregroundColor(disabled ? colorPalette.textGrey5 : scheme == .secondary ? colorPalette.typefaceInvert : colorPalette.primaryBlue)
            .cornerRadius(type.cornerRadius)
    }
}

struct DayChip_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DayChip(container: .preview, title: "Today", type: .chip, scheme: .secondary, size: .large)
            DayChip(container: .preview, title: "Today", type: .chip, scheme: .secondary, size: .small)
            DayChip(container: .preview, title: "Today", type: .chip, scheme: .primary, size: .large)
            DayChip(container: .preview, title: "Today", type: .chip, scheme: .primary, size: .small)
            DayChip(container: .preview, title: "Today", type: .text, scheme: .secondary, size: .large)
            DayChip(container: .preview, title: "Today", type: .text, scheme: .secondary, size: .small)
            DayChip(container: .preview, title: "Today", type: .chip, scheme: .secondary, size: .small, disabled: true)
        }
    }
}
