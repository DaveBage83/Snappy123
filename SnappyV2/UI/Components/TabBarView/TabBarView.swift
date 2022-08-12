//
//  TabBarView.swift
//  SnappyV2
//
//  Created by David Bage on 28/04/2022.
//

import SwiftUI

enum Tab {
    case stores
    case menu
    case account
    case basket
    
    var title: String {
        switch self {
        case .stores: return "Stores"
        case .menu: return "Menu"
        case .account: return "Account"
        case .basket: return "Basket"
        }
    }
    
    var activeIcon: Image {
        switch self {
        case .stores: return Image.Icons.Shop.filled
        case .menu: return Image.Icons.Receipt.filled
        case .account: return Image.Icons.User.filled
        case .basket: return Image.Icons.Basket.filled
        }
    }
    
    var inactiveIcon: Image {
        switch self {
        case .stores: return Image.Icons.Shop.standard
        case .menu: return Image.Icons.Receipt.standard
        case .account: return Image.Icons.User.standard
        case .basket: return Image.Icons.Basket.standard
        }
    }
}

struct TabBarView: View {
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @Environment(\.horizontalSizeClass) var sizeClass
    
    struct Constants {
        struct Tabs {
            static let labelOffset: CGFloat = -10
            static let labelHeight: CGFloat = 14
            
            struct Stores {
                static let height: CGFloat = 20.8
            }
            
            struct Menu {
                static let height: CGFloat = 26
            }
            
            struct Account {
                static let height: CGFloat = 26
            }
            
            struct Basket {
                static let height: CGFloat = 23.11
            }
        }
        
        struct General {
            static let height: CGFloat = 64
            static let hPadding: CGFloat = 35.88
        }
    }
    
    @StateObject var viewModel: TabBarViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private var minimalViewLayout: Bool {
        sizeCategory.size > 4 && sizeClass == .compact
    }
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                tabOption(tab: .stores, height: Constants.Tabs.Stores.height, isSelected: viewModel.selectedTab == .stores, labelValue: nil)
                Spacer()
                tabOption(tab: .menu, height: Constants.Tabs.Menu.height, isSelected: viewModel.selectedTab == .menu, labelValue: nil)
                Spacer()
                tabOption(tab: .account, height: Constants.Tabs.Account.height, isSelected: viewModel.selectedTab == .account, labelValue: nil)
                Spacer()
                tabOption(tab: .basket, height: Constants.Tabs.Basket.height, isSelected: viewModel.selectedTab == .basket, isDisabled: viewModel.container.appState.value.userData.selectedStore.value == nil, labelValue: viewModel.basketTotal)
                    .disabled(viewModel.container.appState.value.userData.selectedStore.value == nil)
            }
            .padding(.horizontal, Constants.General.hPadding)
        }
        .background(colorPalette.secondaryWhite)
        .fixedSize(horizontal: false, vertical: true)
    }
            
    func tabOption(tab: Tab, height: CGFloat, isSelected: Bool, isDisabled: Bool = false, labelValue: String?) -> some View {
        Button {
            viewModel.selectTab(tab)
        } label: {
            VStack(spacing: 2) {
                Spacer()
                (isSelected ? tab.activeIcon : tab.inactiveIcon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(isDisabled ? colorPalette.typefacePrimary.withOpacity(.fifteen) : colorPalette.primaryBlue)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height)
                Spacer()
                
                if minimalViewLayout == false {
                    if let labelValue = labelValue {
                        TabBarBadgeView(contentText: labelValue, container: viewModel.container)
                            .offset(y: Constants.Tabs.labelOffset)
                    } else {
                        Text(tab.title)
                            .font(.Caption1.semiBold())
                            .foregroundColor(colorPalette.typefacePrimary.withOpacity(isDisabled ? .fifteen : .full))
                            .frame(height: Constants.Tabs.labelHeight)
                            .offset(y: Constants.Tabs.labelOffset)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(viewModel: .init(container: .preview))
    }
}
#endif
