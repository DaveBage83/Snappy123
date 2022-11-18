//MIT License
//
//Copyright (c) 2021 Elai Zuberman
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import SwiftUI
import Combine

fileprivate struct AnimatedCheckmark: View {
    
    ///Checkmark color
    var color: Color = .black
    
    ///Checkmark color
    var size: Int = 50
    
    var height: CGFloat {
        return CGFloat(size)
    }
    
    var width: CGFloat {
        return CGFloat(size)
    }
    
    @State private var percentage: CGFloat = .zero
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: height / 2))
            path.addLine(to: CGPoint(x: width / 2.5, y: height))
            path.addLine(to: CGPoint(x: width, y: 0))
        }
        .trim(from: 0, to: percentage)
        .stroke(color, style: StrokeStyle(lineWidth: CGFloat(size / 8), lineCap: .round, lineJoin: .round))
        .animation(Animation.spring().speed(0.75).delay(0.25), value: percentage)
        .onAppear {
            percentage = 1.0
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

fileprivate struct AnimatedXmark: View {
    
    ///xmark color
    var color: Color = .black
    
    ///xmark size
    var size: Int = 50
    
    var height: CGFloat {
        return CGFloat(size)
    }
    
    var width: CGFloat {
        return CGFloat(size)
    }
    
    var rect: CGRect{
        return CGRect(x: 0, y: 0, width: size, height: size)
    }
    
    @State private var percentage: CGFloat = .zero
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxY, y: rect.maxY))
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        .trim(from: 0, to: percentage)
        .stroke(color, style: StrokeStyle(lineWidth: CGFloat(size / 8), lineCap: .round, lineJoin: .round))
        .animation(Animation.spring().speed(0.75).delay(0.25), value: percentage)
        .onAppear {
            percentage = 1.0
        }
        .frame(width: width, height: height, alignment: .center)
    }
}

//MARK: - Main View

public struct AlertToast: Equatable, View{
    public static func == (lhs: AlertToast, rhs: AlertToast) -> Bool { return true }
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.tabViewHeight) var tabViewHeight
    
    public enum BannerAnimation{
        case slide, pop
    }
    
    /// Determine how the alert will be display
    public enum DisplayMode: Equatable{
        
        ///Present at the center of the screen
        case alert
        
        ///Drop from the top of the screen
        case hud
        
        ///Banner from the bottom of the view
        case banner(_ transition: BannerAnimation)
    }
    
    /// Determine what the alert will display
    public enum AlertType: Equatable{
        
        ///Animated checkmark
        case complete(_ color: Color)
        
        ///Animated xmark
        case error(_ color: Color)
        
        ///System image from `SFSymbols`
        case systemImage(_ name: String, _ color: Color)
        
        ///Image from Assets
        case image(_ name: String, _ color: Color)
        
        ///Loading indicator (Circular)
        case loading
        
        ///Only text alert
        case regular
    }
    
    /// Customize Alert Appearance
    public enum AlertStyle: Equatable{
        
        case style(backgroundColor: Color? = nil,
                   titleColor: Color? = nil,
                   subTitleColor: Color? = nil,
                   titleFont: Font? = nil,
                   subTitleFont: Font? = nil)
        
        ///Get background color
        var backgroundColor: Color? {
            switch self{
            case .style(backgroundColor: let color, _, _, _, _):
                return color
            }
        }
        
        /// Get title color
        var titleColor: Color? {
            switch self{
            case .style(_,let color, _,_,_):
                return color
            }
        }
        
        /// Get subTitle color
        var subtitleColor: Color? {
            switch self{
            case .style(_,_, let color, _,_):
                return color
            }
        }
        
        /// Get title font
        var titleFont: Font? {
            switch self {
            case .style(_, _, _, titleFont: let font, _):
                return font
            }
        }
        
        /// Get subTitle font
        var subTitleFont: Font? {
            switch self {
            case .style(_, _, _, _, subTitleFont: let font):
                return font
            }
        }
    }
    
    ///The display mode
    /// - `alert`
    /// - `hud`
    /// - `banner`
    public var displayMode: DisplayMode = .alert
    
    ///What the alert would show
    ///`complete`, `error`, `systemImage`, `image`, `loading`, `regular`
    public var type: AlertType
    
    ///The title of the alert (`Optional(String)`)
    public var title: String? = nil
    
    ///The subtitle of the alert (`Optional(String)`)
    @Binding var subTitle: String
    
    ///Customize your alert appearance
    public var style: AlertStyle? = nil
    
    let tapToDismiss: Bool

    
    ///Full init
    public init(displayMode: DisplayMode = .alert,
                type: AlertType,
                title: String? = nil,
                subTitle: Binding<String>,
                style: AlertStyle? = nil,
                tapToDismiss: Bool){
        
        self.displayMode = displayMode
        self.type = type
        self.title = title
        self._subTitle = subTitle
        self.style = style
        self.tapToDismiss = tapToDismiss
    }
    
    
    ///Short init with most used parameters
    public init(displayMode: DisplayMode,
                type: AlertType,
                title: String? = nil,
                subtitle: Binding<String>,
                tapToDismiss: Bool){
        
        self.displayMode = displayMode
        self.type = type
        self.title = title
        self.tapToDismiss = tapToDismiss
        self._subTitle = subtitle
    }
    
    ///Banner from the bottom of the view
    @ViewBuilder public var banner: some View {
        bannerView
            .padding(.horizontal)
    }
    
    @ViewBuilder private var bannerView: some View {
        GeometryReader { geo in
            VStack{
                Spacer()
                
                //Banner view starts here
                ZStack(alignment: .topTrailing) {
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 10){
                            HStack{
                                switch type{
                                case .complete(let color):
                                    Image(systemName: "checkmark")
                                        .foregroundColor(color)
                                case .error(let color):
                                    Image(systemName: "xmark")
                                        .foregroundColor(color)
                                case .systemImage(let name, let color):
                                    Image(systemName: name)
                                        .foregroundColor(color)
                                case .image(let name, let color):
                                    Image(name)
                                        .foregroundColor(color)
                                case .loading:
                                    ProgressView()
                                case .regular:
                                    EmptyView()
                                }
                                
                                Text(verbatim: title ?? "")
                                    .font(style?.titleFont ?? Font.headline.bold())
                            }
                            
                            if !subTitle.isEmpty {
                                if tapToDismiss {
                                    Text(verbatim: subTitle)
                                        .font(style?.subTitleFont ?? Font.subheadline)
                                        .multilineTextAlignment(.leading)
                                    
                                } else {
                                    Text(verbatim: subTitle)
                                        .font(style?.subTitleFont ?? Font.subheadline)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        if tapToDismiss {
                            Spacer()
                            Text(GeneralStrings.ok.localized)
                                .font(style?.titleFont ?? Font.headline.bold())
                                .frame(maxHeight: .infinity)
                                .padding(.leading)
                                .overlay(Rectangle().fill(Color.white).frame(width: 0.5), alignment: .leading)
                        }
                    }
                    
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .textColor(style?.titleColor ?? nil)
                    .padding()
                    .frame(width: geo.size.width, alignment: .leading)
                    .alertBackground(style?.backgroundColor ?? nil)
                    .cornerRadius(10)
                }
            }
            .padding(.bottom, tabViewHeight)
        }
    }
    
    ///HUD View
    public var hud: some View{
        Group{
            HStack(spacing: 16){
                switch type{
                case .complete(let color):
                    Image(systemName: "checkmark")
                        .hudModifier()
                        .foregroundColor(color)
                case .error(let color):
                    Image(systemName: "xmark")
                        .hudModifier()
                        .foregroundColor(color)
                case .systemImage(let name, let color):
                    Image(systemName: name)
                        .hudModifier()
                        .foregroundColor(color)
                case .image(let name, let color):
                    Image(name)
                        .hudModifier()
                        .foregroundColor(color)
                case .loading:
                    ActivityIndicator()
                case .regular:
                    EmptyView()
                }
                
                if title != nil || subTitle != nil{
                    VStack(alignment: type == .regular ? .center : .leading, spacing: 2){
                        if title != nil{
                            Text(LocalizedStringKey(title ?? ""))
                                .font(style?.titleFont ?? Font.body.bold())
                                .multilineTextAlignment(.leading)
                                .textColor(style?.titleColor ?? nil)
                        }
                        if subTitle != nil{
                            Text(LocalizedStringKey(subTitle ?? ""))
                                .font(style?.subTitleFont ?? Font.footnote)
                                .opacity(0.7)
                                .multilineTextAlignment(.leading)
                                .textColor(style?.subtitleColor ?? nil)
                        }
                    }
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .frame(minHeight: 50)
            .alertBackground(style?.backgroundColor ?? nil)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
            .compositingGroup()
        }
        .padding(.top)
    }
    
    ///Alert View
    public var alert: some View{
        VStack {
            switch type{
            case .complete(let color):
                Spacer()
                AnimatedCheckmark(color: color)
                Spacer()
            case .error(let color):
                Spacer()
                AnimatedXmark(color: color)
                Spacer()
            case .systemImage(let name, let color):
                Spacer()
                Image(systemName: name)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .foregroundColor(color)
                    .padding(.bottom)
                Spacer()
            case .image(let name, let color):
                Spacer()
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .foregroundColor(color)
                    .padding(.bottom)
                Spacer()
            case .loading:
                ActivityIndicator()

            case .regular:
                EmptyView()
            }
            
            VStack(alignment: .leading, spacing: type == .regular ? 8 : 2){
                if title != nil{
                    Text(LocalizedStringKey(title ?? ""))
                        .font(style?.titleFont ?? Font.body.bold())
                        .multilineTextAlignment(.leading)
                        .textColor(style?.titleColor ?? nil)
                }
                if subTitle.isEmpty == false {
                    Text(LocalizedStringKey(subTitle))
                        .font(style?.subTitleFont ?? Font.footnote)
                        .opacity(0.7)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .textColor(style?.subtitleColor ?? nil)
                }
            }
        }
        .padding()
        .withFrame(type != .regular && type != .loading)
        .alertBackground(style?.backgroundColor ?? nil)
        .cornerRadius(10)
    }
    
    ///Body init determine by `displayMode`
    public var body: some View{
        switch displayMode{
        case .alert:
            alert
        case .hud:
            hud
        case .banner:
            banner
        }
    }
}

@available(iOS 13, macOS 11, *)
public struct AlertToastModifier: ViewModifier{
    
    ///Presentation `Binding<Bool>`
    @Binding var isPresenting: Bool
    
    @State var disableAutoDismiss: Bool
        
    ///Duration time to display the alert
    var duration: Double {
        tapToDismiss ? 500 : 4
    }
    
    ///Tap to dismiss alert

    var tapToDismiss: Bool {
        subtitle.count > AppV2Constants.Business.maxAlertCharacterLengthForAutoDismiss || tapToDismissOverride == true
    }
    
    let tapToDismissOverride: Bool
    
    var offsetY: CGFloat = 0
    
    ///Init `AlertToast` View
    var alert: (_ subtitle: String, _ tapToDismiss: Bool) -> AlertToast
    
    ///Completion block returns `true` after dismiss
    var onTap: (() -> ())? = nil
    var completion: (() -> ())? = nil
    
    @State private var workItem: DispatchWorkItem?
    
    @State private var hostRect: CGRect = .zero
    @State private var alertRect: CGRect = .zero
    
    @Binding var subtitle: String
    
    private var screen: CGRect {
        return UIScreen.main.bounds
    }
    
    private var offset: CGFloat{
        return -hostRect.midY + alertRect.height
    }
    
    @ViewBuilder
    public func main() -> some View{
        if isPresenting{
            
            switch alert(subtitle, tapToDismiss).displayMode{
            case .alert:
                ZStack(alignment: .topTrailing) {
                    alert(subtitle, tapToDismiss)

                }
                .onTapGesture {
                    onTap?()
                    if tapToDismiss{
                        withAnimation(Animation.spring()){
                            self.workItem?.cancel()
                                isPresenting = false
                                self.workItem = nil
                            }
                        }
                    }
                    .onDisappear(perform: {
                        completion?()
                    })
                    .transition(AnyTransition.scale(scale: 0.8).combined(with: .opacity))
            case .hud:
                alert(subtitle, tapToDismiss)
                    .overlay(
                        GeometryReader{ geo -> AnyView in
                            let rect = geo.frame(in: .global)
                            
                            if rect.integral != alertRect.integral{
                                
                                DispatchQueue.main.async {
                                    
                                    self.alertRect = rect
                                }
                            }
                            return AnyView(EmptyView())
                        }
                    )
                    .onTapGesture {
                        onTap?()
                        if tapToDismiss{
                            withAnimation(Animation.spring()){
                                self.workItem?.cancel()
                                isPresenting = false
                                self.workItem = nil
                            }
                        }
                    }
                    .onDisappear(perform: {
                        completion?()
                    })
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
            case .banner:
                alert(subtitle, tapToDismiss)

                    .onTapGesture {
                        onTap?()
                        if tapToDismiss{
                            withAnimation(Animation.spring()){
                                self.workItem?.cancel()
                                isPresenting = false
                                self.workItem = nil
                            }
                        }
                    }
                    .onDisappear(perform: {
                        completion?()
                    })
                    .transition(alert(subtitle, tapToDismiss).displayMode == .banner(.slide) ? AnyTransition.slide.combined(with: .opacity) : AnyTransition.move(edge: .bottom))
            }
            
        }
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        switch alert(subtitle, tapToDismiss).displayMode{
        case .banner:
            content
                .overlay(ZStack{
                    main()
                        .offset(y: offsetY)
                }
                            .animation(Animation.spring(), value: isPresenting)
                )
                .valueChanged(value: isPresenting, onChange: { (presented) in
                    if presented{
                        onAppearAction()
                    }
                })
        case .hud:
            content
                .overlay(
                    GeometryReader{ geo -> AnyView in
                        let rect = geo.frame(in: .global)
                        
                        if rect.integral != hostRect.integral{
                            DispatchQueue.main.async {
                                self.hostRect = rect
                            }
                        }
                        
                        return AnyView(EmptyView())
                    }
                        .overlay(ZStack{
                            main()
                                .offset(y: offsetY)
                        }
                                    .frame(maxWidth: screen.width, maxHeight: screen.height)
                                    .offset(y: offset)
                                    .animation(Animation.spring(), value: isPresenting))
                )
                .valueChanged(value: isPresenting, onChange: { (presented) in
                    if presented{
                        onAppearAction()
                    }
                })
        case .alert:
            content
                .overlay(ZStack{
                    main()
                        .offset(y: offsetY)
                }
                            .frame(maxWidth: screen.width, maxHeight: screen.height, alignment: .center)
                            .edgesIgnoringSafeArea(.all)
                            .animation(Animation.spring(), value: isPresenting))
                .valueChanged(value: isPresenting, onChange: { (presented) in
                    if presented{
                        onAppearAction()
                    }
                })
        }
        
    }
    
    private func onAppearAction(){
        guard disableAutoDismiss == false else { return }
        
        if duration > 0{
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                withAnimation(Animation.spring()){
                    isPresenting = false
                    workItem = nil
                }
            }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
        }
    }
}

///Fileprivate View Modifier for dynamic frame when alert type is `.regular` / `.loading`
fileprivate struct WithFrameModifier: ViewModifier{
    
    var withFrame: Bool
    
    var maxWidth: CGFloat = 175
    var maxHeight: CGFloat = 175

    @ViewBuilder
    func body(content: Content) -> some View {
        if withFrame{
            content
                .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: .center)
        }else{
            content
        }
    }
}

///Fileprivate View Modifier to change the alert background
fileprivate struct BackgroundModifier: ViewModifier{
    
    var color: Color?
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if color != nil{
            content
                .background(color)
        }else{
            content
                .background(BlurView())
        }
    }
}

///Fileprivate View Modifier to change the text colors
fileprivate struct TextForegroundModifier: ViewModifier{
    
    var color: Color?
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if color != nil{
            content
                .foregroundColor(color)
        }else{
            content
        }
    }
}

fileprivate extension Image{
    
    func hudModifier() -> some View{
        self
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 20, maxHeight: 20, alignment: .center)
    }
}

public extension View{
    
    /// Return some view w/o frame depends on the condition.
    /// This view modifier function is set by default to:
    /// - `maxWidth`: 175
    /// - `maxHeight`: 175
    fileprivate func withFrame(_ withFrame: Bool) -> some View{
        modifier(WithFrameModifier(withFrame: withFrame))
    }

    /// Present `AlertToast`.
    /// - Parameters:
    ///   - show: Binding<Bool>
    ///   - alert: () -> AlertToast
    /// - Returns: `AlertToast`
    internal func toast(isPresenting: Binding<Bool>, subtitle: Binding<String>, tapToDismissOverride: Bool = false, disableAutoDismiss: Bool = false, offsetY: CGFloat = 0, alert: @escaping (String, Bool) -> AlertToast, onTap: (() -> ())? = nil, completion: (() -> ())? = nil) -> some View{
        modifier(AlertToastModifier(isPresenting: isPresenting, disableAutoDismiss: disableAutoDismiss, tapToDismissOverride: tapToDismissOverride, offsetY: offsetY, alert: alert, onTap: onTap, completion: completion, subtitle: subtitle))
    }
    
    /// Choose the alert background
    /// - Parameter color: Some Color, if `nil` return `VisualEffectBlur`
    /// - Returns: some View
    fileprivate func alertBackground(_ color: Color? = nil) -> some View{
        modifier(BackgroundModifier(color: color))
    }
    
    /// Choose the alert background
    /// - Parameter color: Some Color, if `nil` return `.black`/`.white` depends on system theme
    /// - Returns: some View
    fileprivate func textColor(_ color: Color? = nil) -> some View{
        modifier(TextForegroundModifier(color: color))
    }
    
    @ViewBuilder fileprivate func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        self.onChange(of: value, perform: onChange)
    }
}
