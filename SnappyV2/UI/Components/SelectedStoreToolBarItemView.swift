//
//  SelectedStoreToolBarItemView.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 18/06/2021.
//

import SwiftUI

class SelectedStoreToolbarItemViewModel: ObservableObject {
    @Published var selectedStore: StoreCardDetails?
    @Published var showPopover: Bool = false
    @Published var delivery = true
    
    func tappedSelectStore(selectedStore: StoreCardDetails) {
        self.selectedStore = selectedStore
    }
}

struct SelectedStoreToolBarItemView: View {
    @EnvironmentObject var viewModel: SelectedStoreToolbarItemViewModel
    
    var body: some View {
        HStack {
            if let selectedStore = viewModel.selectedStore {
                Button(action: { viewModel.showPopover = true }) {
                    Image(selectedStore.logo)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(selectedStore.name)
                            .font(.subheadline)
                        
                        Text(viewModel.delivery ? GeneralStrings.delivery.localized : GeneralStrings.collection.localized)
                            .font(.caption)
                            .fontWeight(.ultraLight)
                        
                    }
                }
            } else {
                defaultToolBarItem()
            }
        }
        .frame(width: 150, height: 40, alignment: .center)
    }
    
    func defaultToolBarItem() -> some View {
        Image("default_large_logo")
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 40)
    }
}

struct SelectedStoreToolBarItem_Previews: PreviewProvider {
    static var previews: some View {
        SelectedStoreToolBarItemView()
            .environmentObject(SelectedStoreToolbarItemViewModel())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
