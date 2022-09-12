//
//  BottomSheetModifier.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 07/07/2021.
//

import SwiftUI

// Imported from some other project
public struct BottomSheet<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Constants
    private let closeButtonHeight: CGFloat = 15
    private let closeButtonPadding: CGFloat = 8
    private let headerCornerRadius: CGFloat = 2.5
    private let headerWidth: CGFloat = 40
    private let headerHeight: CGFloat = 5
    private let headerPadding: CGFloat = 5
    private let titlePadding: CGFloat = 10
    private let mainCornerRadius: CGFloat = 10
    
    @Binding var isPresented: Bool
    
    @State private var draggedOffset: CGFloat = 0
    @State private var previousDragValue: DragGesture.Value?
    
    @State private var shouldDismiss: Bool = false
    @State private var height: CGFloat = 0
    @State private var contentFrame: CGRect = .zero
    @State private var didSetScrollView: Bool = false
    
    private let content: Content
    private var onDismiss: () -> Void
    private let animationDelay: TimeInterval = 0.2
    private let container: DIContainer
    private let title: String?
    private let windowSize: CGSize
    private let omitCloseButton: Bool
    
    private var grayBackgroundOpacity: Double { isPresented ? 0.4 : 0 }
    private var dragToDismissThreshold: CGFloat { height * 0.3 }
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    init(
        container: DIContainer,
        isPresented: Binding<Bool>,
        title: String?,
        windowSize: CGSize,
        omitCloseButton: Bool,
        @ViewBuilder content: () -> Content,
        onDismiss: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.content = content()
        self.onDismiss = onDismiss
        self.container = container
        self.title = title
        self.windowSize = windowSize
        self.omitCloseButton = omitCloseButton
    }
    
    private var gesture: some Gesture {
        DragGesture()
            .onChanged({ (value) in
                let offsetY = value.translation.height
                guard offsetY != self.draggedOffset else { return }
                self.draggedOffset = offsetY
            })
            .onEnded({ (value) in
                
                let offsetY = value.translation.height
                if offsetY > self.dragToDismissThreshold {
                    withAnimation {
                        self.shouldDismiss = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                        self.onDismiss()
                    }
                } else {
                    withAnimation {
                        self.draggedOffset = 0
                    }
                }
            })
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                self.fullScreenLightGrayOverlay()
                VStack(spacing: 0) {
                    Spacer()
                    VStack(spacing: 0) {
                        ZStack(alignment: .topTrailing) {
                            if omitCloseButton == false {
                                Button {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                                        self.onDismiss()
                                    }
                                    
                                } label: {
                                    Image.Icons.Xmark.heavy
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: closeButtonHeight)
                                        .foregroundColor(colorPalette.primaryBlue)
                                }
                                .padding(closeButtonPadding)
                            }
                            
                            VStack(spacing: 0) {                                    RoundedRectangle(cornerRadius: headerCornerRadius)
                                    .frame(width: headerWidth, height: headerHeight)
                                    .foregroundColor(.secondary)
                                    .padding(.top, headerPadding)
                                    .padding(.bottom, title == nil ? closeButtonHeight : headerPadding)
                                
                                if let title = title {
                                    Text(title)
                                        .font(.heading4())
                                        .padding(titlePadding)
                                }
                                
                                self.content
                            }
                        }
                        .background(colorPalette.secondaryWhite)
                        .cornerRadius(mainCornerRadius, corners: [.topLeft, .topRight])
                        .modifier(SizeModifier(currentValue: $contentFrame, windowSize: windowSize))
                        .onPreferenceChange(FramePreferenceKey.self) {
                            self.handleFrameChanges($0, geometry: geometry)
                        }
                    }
                    .offset(y: offsetY(geometry: geometry))
                    .gesture(gesture)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    
    private func handleFrameChanges(_ frame: CGRect, geometry: GeometryProxy) {
        if self.height == 0 {
            
            if frame.size.height > UIScreen.main.bounds.height - (geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top) {
                height = UIScreen.main.bounds.height - (geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top)
            } else {
                height = frame.size.height
            }
            
        }
    }
    
    func offsetY(geometry: GeometryProxy) -> CGFloat {
        let contentHeight = self.height
        
        if self.isPresented {
            if shouldDismiss {
                return contentHeight + geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top
            } else {
                let value = 0 + (draggedOffset / 2)
                return value < 0 ? 0 : value
            }
        } else {
            return contentHeight + geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top
        }
    }
    
    func screenHeight(geometry: GeometryProxy) -> CGFloat {
        if geometry.size.height >= UIScreen.main.bounds.height - (geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top) {
            return UIScreen.main.bounds.height
        } else {
            return geometry.size.height
        }
    }
    
    fileprivate func fullScreenLightGrayOverlay() -> some View {
        Color
            .black
            .opacity(grayBackgroundOpacity)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                    self.onDismiss()
                }
            }
    }
}

final class BottomSheetHostingController<Content>: UIHostingController<Content> where Content: View {
    
    override init(rootView: Content) {
        super.init(rootView: rootView)
        commonInit()
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        view.backgroundColor = .clear
    }
}

struct BottomSheetItemModifier<Item, SheetContent>: ViewModifier where Item: Identifiable & Equatable, SheetContent: View {
    
    let container: DIContainer
    @Binding var item: Item?
    let title: String?
    let windowSize: CGSize
    let omitCloseButton: Bool
    let onDismiss: (() -> Void)?
    let content: (Item) -> SheetContent
    private let animationDelay: TimeInterval = 0.1

    @State private var keyWindow: UIWindow?
    @State private var isPresented: Bool = false
    
    private func present() {
        if keyWindow == nil {
            keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow)
        }
        
        var rootViewController = keyWindow?.rootViewController
        
        while true {
            if let presented = rootViewController?.presentedViewController {
                rootViewController = presented
            } else if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.visibleViewController
            } else if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            } else {
                break
            }
        }
        
        let bottomSheetAlreadyPresented = rootViewController is BottomSheetHostingController<BottomSheet<SheetContent>>
        
        if item != nil {
            if !bottomSheetAlreadyPresented {
                if let item = self.item {
                    
                    let view = BottomSheet(container: container, isPresented: $isPresented, title: title, windowSize: windowSize, omitCloseButton: omitCloseButton) {
                        content(item)
                    } onDismiss: {
                        self.item = nil
                    }
                    
                    let bottomSheetViewController = BottomSheetHostingController(rootView: view)
                    rootViewController?.present(bottomSheetViewController, animated: false, completion: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                self.isPresented = true
                            }
                        }
                    })
                }
            } else {
                Swift.print(
                """
                [BottomSheet] Attempted to present toast while another toast is being presented. \
                This is an undefined behavior and will result in view presentation failures.
                """
                )
            }
        } else {
            if bottomSheetAlreadyPresented {
                withAnimation {
                    self.isPresented = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                    rootViewController?.dismiss(animated: false, completion: onDismiss)
                }
            }
            keyWindow = nil
        }
    }
    
    @ViewBuilder func body(content: Content) -> some View {
        content
            .onChange(of: item) { _ in
                present()
            }
    }
}

public extension View {
    
   internal func bottomSheet<Item, Content>(
        container: DIContainer,
        item: Binding<Item?>,
        title: String?,
        windowSize: CGSize,
        omitCloseButton: Bool = false,
        @ViewBuilder content: @escaping (Item) -> Content,
        onDismiss: @escaping () -> Void = {}
    ) -> some View  where Item: Identifiable & Equatable, Content: View {
        
        self.modifier(BottomSheetItemModifier(container: container, item: item, title: title, windowSize: windowSize, omitCloseButton: omitCloseButton, onDismiss: onDismiss, content: content))
    }
}

struct SizeModifier: ViewModifier {
    @Binding var currentValue: CGRect
    @State var fixHeight = true
    @Environment(\.mainWindowSize) var mainWindowSize
    let windowSize: CGSize
    
    private var sizeView: some View {
        GeometryReader { proxy in
            if currentValue.size == .zero {
                Color.clear
                    .preference(
                        key: FramePreferenceKey.self,
                        value: proxy.frame(in: .global)
                    )
                    .onAppear {
                        fixHeight = proxy.frame(in: .global).height < windowSize.height
                    }
            }
        }
    }
    
    func body(content: Content) -> some View {
        content.background(sizeView)
            .fixedSize(horizontal: false, vertical: fixHeight)
    }
}

struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}
