//
//  MemberDashboardOptionsView.swift
//  SnappyV2
//
//  Created by David Bage on 18/03/2022.
//

import SwiftUI

struct MemberDashboardOption: Identifiable {
    let id = UUID()
    let type: MemberDashboardViewModel.OptionType
}

struct MemberDashboardOptionsView: View {
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.horizontalSizeClass) var sizeClass
    
    struct Constants {
        static let gridSpacing: CGFloat = 10
        static let itemWidthAdjustment: CGFloat = 32 // 2 x padding (leading + trailing)
    }
    
    private var minButtonWidthDenominator: CGFloat {
        sizeClass == .compact ? 3 : 6
    }
    
    private var resultGridLayout: [GridItem] {
        [GridItem(.adaptive(minimum: (mainWindowSize.width / minButtonWidthDenominator) - Constants.itemWidthAdjustment), spacing: Constants.gridSpacing, alignment: .top)]
    }
    
    @ObservedObject var viewModel: MemberDashboardViewModel
    
    var body: some View {
        LazyVGrid(columns: resultGridLayout, spacing: Constants.gridSpacing) {
            ForEach(viewModel.visibleOptions, id: \.id) { option in
                MemberDashboardOptionsButton(
                    viewModel: viewModel,
                    option: option.type)
            }
        }
    }
}

#if DEBUG
struct MemberDashboardOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        MemberDashboardOptionsView(viewModel: .init(container: .preview))
            .previewCases()
    }
}
#endif
