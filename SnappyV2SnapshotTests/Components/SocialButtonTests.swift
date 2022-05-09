//
//  SocialButtonTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 09/05/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2

class SocialButtonTests: XCTestCase {
    func test_init_givenSocialButtonPlatformIsFacebookAndButtonSizeIsLarge() {
        let sut = makeSUT(platform: .facebookLogin, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsFacebookAndButtonSizeIsMedium() {
        let sut = makeSUT(platform: .facebookLogin, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsFacebookAndButtonSizeIsSmall() {
        let sut = makeSUT(platform: .facebookLogin, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsGoogleLoginAndButtonSizeIsLarge() {
        let sut = makeSUT(platform: .googleLogin, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsGoogleLoginAndButtonSizeIsMedium() {
        let sut = makeSUT(platform: .googleLogin, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsGoogleLoginAndButtonSizeIsSmall() {
        let sut = makeSUT(platform: .googleLogin, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsGooglePayDarkAndButtonSizeIsLarge() {
        let sut = makeSUT(platform: .googlePayDark, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsGooglePayDarkAndButtonSizeIsMedium() {
        let sut = makeSUT(platform: .googleLogin, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsGooglePayDarkAndButtonSizeIsSmall() {
        let sut = makeSUT(platform: .googleLogin, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsGooglePayLightAndButtonSizeIsLarge() {
        let sut = makeSUT(platform: .googlePayLight, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsGooglePayLightAndButtonSizeIsMedium() {
        let sut = makeSUT(platform: .googlePayLight, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsGooglePayLightAndButtonSizeIsSmall() {
        let sut = makeSUT(platform: .googlePayLight, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsBuyWithGooglePayDarkAndButtonSizeIsLarge() {
        let sut = makeSUT(platform: .buyWithGooglePayDark, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsBuyWithGooglePayDarkAndButtonSizeIsMedium() {
        let sut = makeSUT(platform: .buyWithGooglePayDark, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsBuyWithGooglePayDarkAndButtonSizeIsSmall() {
        let sut = makeSUT(platform: .buyWithGooglePayDark, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsBuyWithGooglePayLightAndButtonSizeIsLarge() {
        let sut = makeSUT(platform: .buyWithGooglePayLight, size: .large)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsBuyWithGooglePayLightAndButtonSizeIsMedium() {
        let sut = makeSUT(platform: .buyWithGooglePayLight, size: .medium)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func test_init_givenSocialButtonPlatformIsBuyWithGooglePayLightAndButtonSizeIsSmall() {
        let sut = makeSUT(platform: .buyWithGooglePayLight, size: .small)
        let iPhone12Snapshot = sut.snapshot(for: .iPhone12(style: .light))
        let iPad8thGenSnapshot = sut.snapshot(for: .iPad8thGen(style: .light))
        
        assert(snapshot: iPhone12Snapshot, sut: sut)
        assert(snapshot: iPad8thGenSnapshot, sut: sut)
    }
    
    func makeSUT(platform: SocialButton.Platform, size: SocialButton.Size) -> SocialButton {
        SocialButton(container: .preview, platform: platform, size: size, action: {})
    }
}
