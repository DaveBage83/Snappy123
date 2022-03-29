//
//  MarketingPreferencesView.swift
//  SnappyV2
//
//  Created by David Bage on 14/03/2022.
//

import SwiftUI
import Combine

class MarketingPreferencesViewModel: ObservableObject {
    private let container: DIContainer
    private let isCheckout: Bool
    
    @Published var marketingPreferencesUpdate: Loadable<UserMarketingOptionsUpdateResponse> = .notRequested
    
    @Published var emailMarketingEnabled = false
    @Published var directMailMarketingEnabled = false
    @Published var notificationMarketingEnabled = false
    @Published var smsMarketingEnabled = false
    @Published var telephoneMarketingEnabled = false
    @Published var marketingPreferencesFetch: Loadable<UserMarketingOptionsFetch> = .notRequested
    @Published var marketingOptionsResponses: [UserMarketingOptionResponse]?
    
    var cancellables = Set<AnyCancellable>()
    
    var marketingPreferencesAreLoading: Bool {
        switch marketingPreferencesFetch {
        case .isLoading(last: _, cancelBag: _):
            return true
        default:
            return false
        }
    }
    
    init(container: DIContainer, isCheckout: Bool) {
        self.container = container
        self.isCheckout = isCheckout
        
        getMarketingPreferences()
        setupMarketingPreferences()
        setupMarketingOptionsResponses()
    }
    
    private func setupMarketingOptionsResponses() {
        $marketingOptionsResponses
            .receive(on: RunLoop.main)
            .sink { [weak self] marketingResponses in
                guard let self = self else { return }
                // Set marketing properties
                self.emailMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.email.rawValue }.first?.opted == .in
                self.directMailMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.directMail.rawValue }.first?.opted == .in
                self.notificationMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.notification.rawValue }.first?.opted == .in
                self.smsMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.sms.rawValue }.first?.opted == .in
                self.telephoneMarketingEnabled = marketingResponses?.filter { $0.type == MarketingOptions.telephone.rawValue }.first?.opted == .in
            }
            .store(in: &cancellables)
    }
    
    private func setupMarketingPreferences() {
        $marketingPreferencesFetch
            .map { preferencesFetch in
                return preferencesFetch.value?.marketingOptions
            }
            .assignWeak(to: \.marketingOptionsResponses, on: self)
            .store(in: &cancellables)
    }
    
    private func getMarketingPreferences() {
        container.services.userService.getMarketingOptions(options: loadableSubject(\.marketingPreferencesFetch), isCheckout: isCheckout, notificationsEnabled: true)
    }
    
    private func updateMarketingPreferences() {
        let preferences = [
            UserMarketingOptionRequest(type: MarketingOptions.email.rawValue, opted: emailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.directMail.rawValue, opted: directMailMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.notification.rawValue, opted: notificationMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.sms.rawValue, opted: smsMarketingEnabled.opted()),
            UserMarketingOptionRequest(type: MarketingOptions.telephone.rawValue, opted: telephoneMarketingEnabled.opted()),
        ]
                
        container.services.userService.updateMarketingOptions(result: loadableSubject(\.marketingPreferencesUpdate), options: preferences)
    }
    
    func marketingUpdateRequested() {
        self.updateMarketingPreferences()
    }
}

struct MarketingPreferencesView: View {
    struct Constants {
        static let bottomPadding: CGFloat = 4
    }
    
    @ObservedObject var viewModel: MarketingPreferencesViewModel

    var body: some View {
        VStack(alignment: .leading) {
            marketingPreference(type: .email)
            marketingPreference(type: .directMail)
            marketingPreference(type: .notification)
            marketingPreference(type: .sms)
            marketingPreference(type: .telephone)
        }
    }
    
    func marketingPreference(type: MarketingOptions) -> some View {
        HStack {
            if viewModel.marketingPreferencesAreLoading {
                ProgressView()
            } else {
                Button {
                    switch type {
                    case .email:
                        viewModel.emailMarketingEnabled.toggle()
                    case .notification:
                        viewModel.notificationMarketingEnabled.toggle()
                    case .sms:
                        viewModel.smsMarketingEnabled.toggle()
                    case .telephone:
                        viewModel.telephoneMarketingEnabled.toggle()
                    case .directMail:
                        viewModel.directMailMarketingEnabled.toggle()
                    }
                    
                } label: {
                    switch type {
                    case .email:
                        viewModel.emailMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .notification:
                        viewModel.notificationMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .sms:
                        viewModel.smsMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .telephone:
                        viewModel.telephoneMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    case .directMail:
                        viewModel.directMailMarketingEnabled ? Image.General.Checkbox.checked : Image.General.Checkbox.unChecked
                    }
                }
                .font(.snappyTitle2)
                .foregroundColor(.snappyBlue)
            }
            Text(type.title())
                .font(.snappyCaption)
                .foregroundColor(.snappyTextGrey1)
            Spacer()
        }
        .padding(.bottom, Constants.bottomPadding)
    }
}

struct MarketingPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        MarketingPreferencesView(viewModel: .init(container: .preview, isCheckout: false))
    }
}

extension Bool {
    func opted() -> UserMarketingOptionState {
        self ? .in : .out
    }
}
