//
//  SettingsButton.swift
//  SnappyV2
//
//  Created by David Bage on 28/09/2022.
//

import SwiftUI

class SettingsButtonViewModel: ObservableObject {
    let container: DIContainer
    @Published var showSettingsView = false
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func settingsButtonTapped() {
        showSettingsView = true
    }
    
    func settingsDismissed() {
        showSettingsView = false
    }
}

struct SettingsButton: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: SettingsButtonViewModel
    
    struct Constants {
        static let buttonHeight: CGFloat = 24
    }
    
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        Button {
            viewModel.settingsButtonTapped()
        } label: {
            Image.Icons.Gears.heavy
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Constants.buttonHeight)
                .foregroundColor(colorPalette.primaryBlue)
        }
        .sheet(isPresented: $viewModel.showSettingsView) {
            NavigationView {
                MemberDashboardSettingsView(
                    viewModel: .init(container: viewModel.container),
                    marketingPreferencesViewModel: .init(container: viewModel.container, viewContext: .settings, hideAcceptedMarketingOptions: false),
                    pushNotificationsMarketingPreferenceViewModel: .init(container: viewModel.container, viewContext: .settings, hideAcceptedMarketingOptions: false),
                    dismissViewHandler: {
                        viewModel.settingsDismissed()
                        
                    })
            }
        }
    }
}

#if DEBUG
struct SettingsButton_Previews: PreviewProvider {
    static var previews: some View {
        SettingsButton(viewModel: .init(container: .preview))
    }
}
#endif
