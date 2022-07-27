//
//  EditableCardContainer.swift
//  SnappyV2
//
//  Created by David Bage on 25/07/2022.
//

import SwiftUI

struct EditableCardContainer<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    typealias DeleteStrings = Strings.EditableCardContainer.Delete

    private enum EditableCardButtonType {
        case edit
        case delete
        
        var icon: Image {
            switch self {
            case .edit:
                return Image.Icons.Pen.penCircle
            case .delete:
                return Image.Icons.CircleTrash.filled
            }
        }
        
        func backgroundColor(colorPalette: ColorPalette) -> Color {
            switch self {
            case .edit:
                return colorPalette.primaryBlue.withOpacity(.eighty)
            case .delete:
                return colorPalette.primaryRed
            }
        }
    }
        
    // Unable to use static properties in view with injected content so constants listed as standard properties
    private let cardHeight: CGFloat = 80
    private let iconWidth: CGFloat = 20
    private let iconPadding: CGFloat = 8
    private let buttonWidth: CGFloat = 38
    
    let container: DIContainer
    let deleteAction: () -> Void
    let editAction: () -> Void
    
    var content: () -> Content
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: container, colorScheme: colorScheme)
    }
    
    @State var isPresentingConfirm = false
    
    var body: some View {
        HStack {
            HStack(content: content)
                .padding()
            
            Spacer()
            
            buttonStack
        }
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .background(colorPalette.secondaryWhite)
        .standardCardFormat()
    }
    
    private var buttonStack: some View {
        VStack(spacing: 0) {
            actionButton(action: {
                editAction()
            }, buttonType: .edit)
            
            deleteButtonWithAlert
        }
    }
    
    @ViewBuilder private var deleteButtonWithAlert: some View {
        if #available(iOS 15.0, *) { // If no iOS 15 user will just not see the confirmation dialog but can still delete
            actionButton(action: {
                isPresentingConfirm = true
            }, buttonType: .delete)
            .confirmationDialog("",
                                isPresented: $isPresentingConfirm) {
                Button(DeleteStrings.areYouSure.localized, role: .destructive) {
                    deleteAction()
                }
            } message: {
                Text(DeleteStrings.cannotUndo.localized)
            }
        } else {
            actionButton(action: {
                deleteAction()
            }, buttonType: .delete)
        }
    }
    
    private func actionButton(action: @escaping () -> Void, buttonType: EditableCardButtonType) -> some View {
        VStack(spacing: 0) {
            Button {
                action()
            } label: {
                buttonType.icon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: iconWidth)
                    .padding(iconPadding)
            }
            .frame(maxHeight: .infinity)
            .frame(width: buttonWidth)
            .background(buttonType.backgroundColor(colorPalette: colorPalette))
        }
    }
}

#if DEBUG
struct EditableCardContainer_Previews: PreviewProvider {
    static var previews: some View {
        EditableCardContainer(container: .preview, deleteAction: { print("Delete") }, editAction: { print("Edit") }, content: {
            Text("This is some cool content")
        })
    }
}
#endif
