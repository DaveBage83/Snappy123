//
//  SnappyMultilineTextField.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 13/07/2022.
//
// Solution provided by https://stackoverflow.com/questions/56471973/how-do-i-create-a-multiline-textfield-in-swiftui/58639072#58639072

import SwiftUI
import UIKit

struct UITextViewWrapper: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    typealias UIViewType = UITextView

    let container: DIContainer
    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    @Binding var isFocused: Bool
    let minHeight: CGFloat
    var onDone: (() -> Void)?
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = .body1Regular
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        if nil != onDone {
            textField.returnKeyType = .done
        }

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }

        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight, minHeight: minHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>, minHeight: CGFloat) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height > minHeight ? newSize.height : minHeight // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, minHeight: minHeight, isFocused: $isFocused, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?
        @Binding var isFocused: Bool
        let minHeight: CGFloat

        init(text: Binding<String>, height: Binding<CGFloat>, minHeight: CGFloat, isFocused: Binding<Bool>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.minHeight = minHeight
            self._isFocused = isFocused
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight, minHeight: minHeight)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.isFocused = true
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.isFocused = false
            }
        }
    }
}

struct SnappyMultilineTextField: View {
    @Environment(\.colorScheme) var colorScheme
    
    struct Constants {
        static let padding: CGFloat = 10
        static let cornerRadius: CGFloat = 8
        static let lineWidth: CGFloat = 1
        static let placeholderTopPadding: CGFloat = 10
        static let placeholderLeadingPadding: CGFloat = 5
    }
    
    let container: DIContainer
    private var placeholder: String
    private var onCommit: (() -> Void)?
    let minHeight: CGFloat

    @Binding private var text: String
    @State var isFocused = false
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat
    @State private var showingPlaceholder = false
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }

    init (container: DIContainer, placeholder: String = "", text: Binding<String>, minHeight: CGFloat, onCommit: (() -> Void)? = nil) {
        self.container = container
        self.placeholder = placeholder
        self.minHeight = minHeight
        self.onCommit = onCommit
        self._dynamicHeight = State<CGFloat>(initialValue: minHeight)
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    var body: some View {
        VStack {
            UITextViewWrapper(container: container, text: self.internalText, calculatedHeight: $dynamicHeight, isFocused: $isFocused, minHeight: minHeight, onDone: onCommit)
                .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
                .background(placeholderView, alignment: .topLeading)
                .padding(Constants.padding)
                .background(colorPalette.secondaryWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(isFocused ? colorPalette.primaryBlue : colorPalette.textGrey4, lineWidth: Constants.lineWidth)
                )
        }
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder)
                    .foregroundColor(colorPalette.typefacePrimary.withOpacity(.eighty))
                    .font(.Body1.regular())
                    .padding(.leading, Constants.placeholderLeadingPadding)
                    .padding(.top, Constants.placeholderTopPadding)
            }
        }
    }
}
