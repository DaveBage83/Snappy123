//
//  View+Snapshot.swift
//  SnappyV2SnapshotTests
//
//  Created by Henrik Gustavii on 02/12/2021.
//

import SwiftUI

// lifted from previous projects
typealias Snapshot = (image: UIImage, name: String)

extension View {
    func snapshot(for configuration: SnapshotConfiguration) -> Snapshot {
        let hostingController = UIHostingController(rootView: self)
        return SnapshotWindow(configuration: configuration, root: hostingController).snapshot()
    }
}

struct SnapshotConfiguration {
    
    /// layout guide reference: https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/adaptivity-and-layout/
    
    let name: String
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection
    
    init(name: String = #function, size: CGSize, safeAreaInsets: UIEdgeInsets, layoutMargins: UIEdgeInsets, traitCollection: UITraitCollection) {
        self.name = name.components(separatedBy: "(").first ?? ""
        self.size = size
        self.safeAreaInsets = safeAreaInsets
        self.layoutMargins = layoutMargins
        self.traitCollection = traitCollection
    }
    
    static func customFrame(_ frame: CGSize, style: UIUserInterfaceStyle = .light, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: frame,
            safeAreaInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            layoutMargins: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            traitCollection: UITraitCollection(traitsFrom: []))
    }
    
    static func iPhone8(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 375, height: 667),
            safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: UITraitCollection(traitsFrom: [
                .init(forceTouchCapability: .available),
                .init(layoutDirection: .leftToRight),
                .init(preferredContentSizeCategory: contentSize),
                .init(userInterfaceIdiom: .phone),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(displayScale: 2),
                .init(displayGamut: .P3),
                .init(userInterfaceStyle: style)
            ]))
    }
    
    static func iPhone12(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 390, height: 884),
            safeAreaInsets: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 55, left: 8, bottom: 42, right: 8),
            traitCollection: UITraitCollection(traitsFrom: [
                .init(forceTouchCapability: .available),
                .init(layoutDirection: .leftToRight),
                .init(preferredContentSizeCategory: contentSize),
                .init(userInterfaceIdiom: .phone),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(displayScale: 3),
                .init(displayGamut: .P3),
                .init(userInterfaceStyle: style)
            ]))
    }
    
    static func iPad8thGen(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 810, height: 1080),
            safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: UIEdgeInsets(top: 28, left: 8, bottom: 8, right: 8),
            traitCollection: UITraitCollection(traitsFrom: [
                .init(forceTouchCapability: .available),
                .init(layoutDirection: .leftToRight),
                .init(preferredContentSizeCategory: contentSize),
                .init(userInterfaceIdiom: .phone),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(displayScale: 2),
                .init(displayGamut: .P3),
                .init(userInterfaceStyle: style)
            ]))
    }
}

private final class SnapshotWindow: UIWindow {
    
    private(set) var configuration: SnapshotConfiguration = .iPhone12(style: .light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        layoutMargins = configuration.layoutMargins
        rootViewController = root
        isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }
    
    func snapshot() -> Snapshot {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        let image = renderer.image { layer.render(in: $0.cgContext) }
        let name = configuration.name
        
        return (image, name)
    }
}
