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
        case .stores: return Image.Icons.Stores.selected
        case .menu: return Image.Icons.Menu.selected
        case .account: return Image.Icons.Account.selected
        case .basket: return Image.Icons.Basket.selected
        }
    }
    
    var inactiveIcon: Image {
        switch self {
        case .stores: return Image.Icons.Stores.standard
        case .menu: return Image.Icons.Menu.standard
        case .account: return Image.Icons.Account.standard
        case .basket: return Image.Icons.Basket.standard
        }
    }
}

struct TabBarView: View {
    struct Constants {
        struct Tabs {
            static let labelOffset: CGFloat = -10
            static let labelWidth: CGFloat = 44
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
        }
    }
    
    @StateObject var viewModel: TabBarViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack {
            tabOption(tab: .stores, height: Constants.Tabs.Stores.height, isSelected: viewModel.selectedTab == .stores, labelValue: nil)
            Spacer()
            tabOption(tab: .menu, height: Constants.Tabs.Menu.height, isSelected: viewModel.selectedTab == .menu, labelValue: nil)
            Spacer()
            tabOption(tab: .account, height: Constants.Tabs.Account.height, isSelected: viewModel.selectedTab == .account, labelValue: nil)
            Spacer()
            tabOption(tab: .basket, height: Constants.Tabs.Basket.height, isSelected: viewModel.selectedTab == .basket, labelValue: viewModel.basketTotal)
        }
        .frame(height: Constants.General.height)
    }
            
    func tabOption(tab: Tab, height: CGFloat, isSelected: Bool, labelValue: String?) -> some View {
        Button {
            viewModel.selectTab(tab)
        } label: {
            VStack(spacing: 0) {
                Spacer()
                (isSelected ? tab.activeIcon : tab.inactiveIcon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(colorPalette.primaryBlue)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height)
                Spacer()
                if let labelValue = labelValue {
                    TabBarBadgeView(contentText: labelValue, container: viewModel.container)
                        .offset(y: Constants.Tabs.labelOffset)
                } else {
                    Text(tab.title)
                        .font(.Caption1.semiBold())
                        .foregroundColor(colorPalette.textBlack)
                        .frame(width: Constants.Tabs.labelWidth, height: Constants.Tabs.labelHeight)
                        .offset(y: Constants.Tabs.labelOffset)
                }
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(viewModel: .init(container: .preview))
    }
}
