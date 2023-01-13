//
//  VersionUpdateAlert.swift
//  SnappyV2
//
//  Created by David Bage on 23/12/2022.
//

import SwiftUI

class VersionUpdateAlertViewModel: ObservableObject {
    let container: DIContainer
    let prompt: String
    let appstoreLink: URL
    
    init(container: DIContainer, prompt: String, appstoreLink: URL) {
        self.container = container
        self.prompt = prompt
        self.appstoreLink = appstoreLink
    }
    
    func navigateToAppStore() {
        container.appState.value.userData.versionUpdateChecked = true
        UIApplication.shared.open(appstoreLink)
    }
}

struct VersionUpdateAlert: View {
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Typealiases
    typealias VersionUpdateStrings = Strings.VersionUpateAlert
        
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    @StateObject var viewModel: VersionUpdateAlertViewModel
    
    // MARK: - Constants
    struct Constants {
        static let vStackSpacing: CGFloat = 11
        static let opacity: CGFloat = 0.3
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(Constants.opacity))
                .ignoresSafeArea()
            
            VStack(spacing: Constants.vStackSpacing) {
                Text(VersionUpdateStrings.title.localized)
                    .bold()
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                
                Text(viewModel.prompt)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                    Divider()
                    
                    Button(action: {
                        viewModel.navigateToAppStore()
                    }) {
                        Text(VersionUpdateStrings.buttonText.localized)
                    }
                    .padding(.bottom)
            }
            .customAlert(container: viewModel.container)
        }
        .ignoresSafeArea(.all)
    }
}

#if DEBUG
struct VersionUpdateAlert_Previews: PreviewProvider {
    static var previews: some View {
        VersionUpdateAlert(viewModel: .init(container: .preview, prompt: "Let's go", appstoreLink: URL(string: "")!))
    }
}
#endif
