//
//  ColorPaletteTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 04/05/2022.
//

import XCTest
import Combine
@testable import SnappyV2
import SwiftUI

class ColorPaletteTests: XCTestCase {

    func test_whenBusinessProfileColorsAreNilAndColorSchemeIsLight_thenUseDefaultColors() {
        let sut = makeSUT(colorScheme: .light, businessProfile: BusinessProfile.mockedDataFromAPI)
        
        XCTAssertEqual(sut.alertSuccess, Color("Success"))
    }
    
    func test_whenBusinessProfileColorsAreNilAndColorSchemeIsDark_thenUseDefaultColors() {
        let sut = makeSUT(colorScheme: .dark, businessProfile: BusinessProfile.mockedDataFromAPI)
        
        XCTAssertEqual(sut.alertSuccess, Color("Success"))
    }
    
    func test_whenBusinessProfileColorsArePopulatedAndColorSchemeIsLight_thenUseProfileLightColors() {
        let sut = makeSUT(colorScheme: .light, businessProfile: BusinessProfile.mockedDataFromAPIWithColors)
        
        let successLightColor = Color(hex: "#eb4031")
        
        XCTAssertEqual(sut.alertSuccess, successLightColor)
    }
    
    func test_whenBusinessProfileColorsArePopulatedAndColorSchemeIsDark_thenUseProfileDarkColors() {
        let sut = makeSUT(colorScheme: .dark, businessProfile: BusinessProfile.mockedDataFromAPIWithColors)
        
        let successDarkColor = Color(hex: "#eb3471")
        
        XCTAssertEqual(sut.alertSuccess, successDarkColor)
    }
    
    func test_whenBusinessProfileColorsArePopulatedAndColorSchemeIsDark_givenThatDarkColorIsNil_thenUseProfileLightColors() {
        let sut = makeSUT(colorScheme: .dark, businessProfile: BusinessProfile.mockedDataFromAPIWithColorsWithoutDarkVariants)
        
        let successLightColor = Color(hex: "#eb4031")
        
        XCTAssertEqual(sut.alertSuccess, successLightColor)
    }
    
    func test_whenBusinessProfileColorsArePopulatedButHexValuesAreNotValidColors_thenUseDefaultColors() {
        let sut = makeSUT(colorScheme: .dark, businessProfile: BusinessProfile.mockedDataFromAPIWithColorsInvalidHexValues)
                
        XCTAssertEqual(sut.alertSuccess, Color("Success"))
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), colorScheme: ColorScheme, businessProfile: BusinessProfile) -> ColorPalette {
        
        container.appState.value.businessData.businessProfile = businessProfile
        
        let sut = ColorPalette(container: container, colorScheme: colorScheme)
        
        return sut
    }
}
