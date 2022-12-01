//
//  SnappyTextfieldWithHistory.swift
//  SnappyV2
//
//  Created by David Bage on 30/11/2022.
//

import SwiftUI
import Combine

@MainActor
class SnappyTextfieldWithHistoryViewModel: ObservableObject {
    let container: DIContainer
    let buttonAction: (() -> Void)?
    let internalButtonAction: (() -> Void)?
    @Published var showPostcodeDropdown = false
    @Published var postcodeSearchResults = [String]()
    @Published var postcodeSearchString = ""
    @Published var storedPostcodes: [Postcode]?

    private var cancellables = Set<AnyCancellable>()

    init(container: DIContainer, buttonAction: (() -> Void)? = nil, internalButtonAction: (() -> Void)? = nil) {
        self.container = container
        self.buttonAction = buttonAction
        self.internalButtonAction = internalButtonAction
        setupPostcodeString()
        populateStoredPostcodes()
    }
    
    private func populateStoredPostcodes() {
        Task {
            self.storedPostcodes = await self.container.services.postcodeService.getAllPostcodes()
            print("*** STORED: \(storedPostcodes)")
        }
    }
    
    func hidePostcodeDropdown() {
        if showPostcodeDropdown {
            showPostcodeDropdown = false
        }
    }
    
    func postcodeTapped(postcode: String) {
        postcodeSearchString = postcode
        postcodeSearchResults = []
        showPostcodeDropdown = false
    }
    
    private func setupPostcodeString() {
        $postcodeSearchString
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] postcode in
                guard let self = self else { return }
                
                self.populateStoredPostcodes()
                
                if postcode.isEmpty == false {
                    self.postcodeSearchResults = self.storedPostcodes?.filter { $0.postcode.removeWhitespace().contains(postcode.removeWhitespace()) }.compactMap { $0.postcode } ?? []
                    
                    print("Results: \(self.postcodeSearchResults)")
                    
                    if self.postcodeSearchResults.count == 1 && self.postcodeSearchResults.first == self.postcodeSearchString {
                        self.showPostcodeDropdown = false
                    } else if self.postcodeSearchResults.count > 0 {
                        self.showPostcodeDropdown = true
                    }
                    
                } else {
                    self.postcodeSearchResults = self.storedPostcodes?.compactMap { $0.postcode } ?? []
                }
            }
            .store(in: &cancellables)
    }
}

struct SnappyTextfieldWithHistory: View {
    @Environment(\.colorScheme) var colorScheme
    struct Constants {
        struct PostcodesDropDown {
            static let spacing: CGFloat = 10
            static let hPadding: CGFloat = 16
            static let vPadding: CGFloat = 6
            static let width: CGFloat = 250
        }
    }
    
    @StateObject var viewModel: SnappyTextfieldWithHistoryViewModel
    
    @Binding var text: String
    @Binding var hasError: Bool
    @Binding var isLoading: Bool
    
    private var colorPalette: ColorPalette {
        .init(container: viewModel.container, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SnappyTextFieldWithButton(
                container: viewModel.container,
                text: $text,
                hasError: $hasError,
                isLoading: $isLoading,
                showInvalidFieldWarning: .constant(false),
                autoCaps: .allCharacters,
                labelText: GeneralStrings.Search.searchPostcode.localized,
                largeLabelText: GeneralStrings.Search.search.localized,
                warningText: nil,
                keyboardType: nil,
                mainButton: (GeneralStrings.Search.search.localized, {
                    Task {
//                        try await viewModel.postcodeSearchTapped()
                    }
                }),
                mainButtonLargeTextLogo: Image.Icons.MagnifyingGlass.standard,
                internalButton: (Image.Icons.LocationCrosshairs.standard, {
                    Task {
//                        await viewModel.searchViaLocationTapped()
                    }
                }))
            Rectangle() // Used to attach the overlay beneath the textfield
                .frame(height: 0)
            .overlay(
                postcodesDropDown,
                alignment: .topLeading)
        }
    }
    
    @ViewBuilder private var postcodesDropDown: some View {
        if viewModel.showPostcodeDropdown {
            VStack(alignment: .leading, spacing: Constants.PostcodesDropDown.spacing) {
                    ForEach($viewModel.postcodeSearchResults, id: \.self) { postcode in
                            Button {
                                viewModel.postcodeTapped(postcode: postcode.wrappedValue)
                            } label: {
                                Text(postcode.wrappedValue)
                                    .font(.Body2.semiBold())
                                    .foregroundColor(colorPalette.typefacePrimary)
                            }
                            .padding(.horizontal, Constants.PostcodesDropDown.hPadding)
                            .padding(.vertical, Constants.PostcodesDropDown.vPadding)
                            
                            Divider()
                        }
                }
            .frame(width: Constants.PostcodesDropDown.width)
                .background(Color.white)
                .standardCardFormat()
        }
    }
}

#if DEBUG
struct SnappyTextfieldWithHistory_Previews: PreviewProvider {
    static var previews: some View {
        SnappyTextfieldWithHistory(viewModel: .init(container: .preview), text: .constant(""), hasError: .constant(false), isLoading: .constant(false))
    }
}
#endif
