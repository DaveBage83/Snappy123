//
//  ColorPalette.swift
//  SnappyV2
//
//  Created by David Bage on 03/05/2022.
//

import SwiftUI

struct ColorPalette {
    let container: DIContainer

    var colorScheme: ColorScheme // Determines whether we are in dark or light mode
    
    private func dynamicColor(lightColor: Color?, darkColor: Color?, defaultColor: Color) -> Color {
        switch colorScheme {
        case .dark:
            return darkColor ?? lightColor ?? defaultColor // If no valid dark mode colour available in the BusinessProfile use light mode, otherwise use Snappy defaults
        default:
            return lightColor ?? defaultColor
        }
    }
    
    var alertSuccess: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.success?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.success?.dark),
            defaultColor: Color("Success"))
    }
    
    var alertWarning: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.warning?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.warning?.dark),
            defaultColor: Color("Warning"))
    }
    
    var alertHighlight: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.highlight?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.highlight?.dark),
            defaultColor: Color("Highlight"))
    }
    
    var alertOfferBasket: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.offerBasket?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.offerBasket?.dark),
            defaultColor: Color("OfferBasket"))
    }
    
    var backgroundMain: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.backgroundMain?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.backgroundMain?.dark),
            defaultColor: Color("Main"))
    }
    
    var backgroundModalGB: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.modalBG?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.modalBG?.dark),
            defaultColor: Color("ModalBG"))
    }
    
    var primaryBlue: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.primaryBlue?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.primaryBlue?.dark),
            defaultColor: Color("SnappyBlue"))
    }
    
    var primaryRed: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.primaryRed?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.primaryRed?.dark),
            defaultColor: Color("SnappyRed"))
    }
    
    var secondaryWhite: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.secondaryWhite?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.secondaryWhite?.dark),
            defaultColor: Color("White"))
    }
    
    var secondaryBakery: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.secondaryBakery?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.secondaryBakery?.dark),
            defaultColor: Color("Bakery"))
    }
    
    var secondaryButcher: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.secondaryButcher?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.secondaryButcher?.dark),
            defaultColor: Color("Butcher"))
    }
    
    var secondaryConvenience: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.secondaryConvenience?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.secondaryConvenience?.dark),
            defaultColor: Color("Convenience"))
    }
    
    var secondaryDark: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.secondaryDark?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.secondaryDark?.dark),
            defaultColor: Color("Dark"))
    }
    
    var typefacePrimary: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textBlack?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textBlack?.dark),
            defaultColor: Color("TypefacePrimary"))
    }
    
    var textGrey1: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey1?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey1?.dark),
            defaultColor: Color("Grey1"))
    }
    
    var textGrey2: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey2?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey1?.dark),
            defaultColor: Color("Grey2"))
    }
    
    var textGrey3: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey3?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey3?.dark),
            defaultColor: Color("Grey3"))
    }
    
    var textGrey4: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey4?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey4?.dark),
            defaultColor: Color("Grey4"))
    }
    
    var textGrey5: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey5?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey5?.dark),
            defaultColor: Color("Grey5"))
    }
    
    var textGrey6: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey6?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey6?.dark),
            defaultColor: Color("Grey6"))
    }
    
    var typefaceInvert: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textWhite?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textWhite?.dark),
            defaultColor: Color("TypefaceInvert"))
    }
    
    var typefaceDarkInvert: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textGrey1?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.textWhite?.dark),
            defaultColor: Color("TypefaceDarkInvert"))
    }
    
    var twoStar: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.twoStar?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.twoStar?.dark),
            defaultColor: Color("twoStar"))
    }
    
    var twoPointFiveStar: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.twoPointFiveStar?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.twoPointFiveStar?.dark),
            defaultColor: Color("twoPointFiveStar"))
    }
    
    var threeStar: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.threeStar?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.threeStar?.dark),
            defaultColor: Color("threeStar"))
    }
    
    var threePointFiveStar: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.threePointFiveStar?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.threePointFiveStar?.dark),
            defaultColor: Color("threePointFiveStar"))
    }
    
    var fourStar: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.fourStar?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.fourStar?.dark),
            defaultColor: Color("fourStar"))
    }
    
    var fourPointFiveStar: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.fourPointFiveStar?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.fourPointFiveStar?.dark),
            defaultColor: Color("fourPointFiveStar"))
    }
    
    var fiveStar: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.fiveStar?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.fiveStar?.dark),
            defaultColor: Color("fiveStar"))
    }
    
    var offer: Color {
        return dynamicColor(
            lightColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.offer?.light),
            darkColor: Color(hex: container.appState.value.businessData.businessProfile?.colors?.offer?.dark),
            defaultColor: Color("Offer"))
    }
}
