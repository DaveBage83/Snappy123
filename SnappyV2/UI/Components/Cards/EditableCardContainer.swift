//
//  EditableCardContainer.swift
//  SnappyV2
//
//  Created by David Bage on 25/07/2022.
//

import SwiftUI

class EditableCardContainerViewModel: ObservableObject {
    let container: DIContainer
    let deleteAction: (() -> Void)?
    let editAction: (() -> Void)?
    
    var showEditButton: Bool {
        editAction != nil
    }
    
    var showDeleteButton: Bool {
        deleteAction != nil
    }
    
    var includeMiddleButtonDivider: Bool {
        showEditButton && showDeleteButton
    }
    
    init(container: DIContainer, editAction: (() -> Void)?, deleteAction: (() -> Void)?) {
        self.container = container
        self.editAction = editAction
        self.deleteAction = deleteAction
    }
}

struct EditableCardContainer<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    typealias DeleteStrings = Strings.EditableCardContainer.Delete
    @Binding var hasWarning: Bool?
    @Binding var editDisabled: Bool
    @Binding var deleteDisabled: Bool
    
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
        
        func foregroundColor(colorPalette: ColorPalette, disabled: Binding<Bool>) -> Color {
            switch self {
            case .edit:
                return disabled.wrappedValue ? colorPalette.primaryBlue.withOpacity(.thirty) : colorPalette.primaryBlue
            case .delete:
                return disabled.wrappedValue ? colorPalette.primaryRed.withOpacity(.thirty) : colorPalette.primaryRed
            }
        }
    }
    
    // Unable to use static properties in view with injected content so constants listed as standard properties
    private let iconWidth: CGFloat = 24
    private let iconPadding: CGFloat = 8
    private let buttonWidth: CGFloat = 38
    private let buttonStackWidth: CGFloat = 45
    private let buttonPadding: CGFloat = 3

    var content: () -> Content
    
    private var colorPalette: ColorPalette {
        ColorPalette(container: viewModel.container, colorScheme: colorScheme)
    }
    
    @State var isPresentingConfirm = false
    @StateObject var viewModel: EditableCardContainerViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
            
            HStack {
                HStack(content: content)
                    .padding()
                
                Spacer()
                
                buttonStack
            }
            .background(hasWarning == true ? colorPalette.primaryRed.withOpacity(.twenty) : colorPalette.secondaryWhite)
        }
        .fixedSize(horizontal: false, vertical: true)
        .onTapGesture {
            if editDisabled == false {
                (viewModel.editAction ?? {})()
            }
        }
        .frame(maxWidth: .infinity)
        .standardCardFormat()
    }
    
    private var buttonStack: some View {
        VStack(spacing: 0) {
            if viewModel.showEditButton {
                actionButton(action: {
                    (viewModel.editAction ?? {})()
                }, buttonType: .edit, disabled: $editDisabled)
                .disabled(editDisabled)
            }
            
            if viewModel.includeMiddleButtonDivider {
                Divider()
                    .background(colorPalette.textGrey3)
            }
            
            if viewModel.showDeleteButton {
                deleteButtonWithAlert
                    .disabled(deleteDisabled)
            }
        }
        .frame(width: buttonStackWidth)
        .overlay(Divider().background(colorPalette.textGrey3), alignment: .leading)
        .padding(buttonPadding)
        .background(Color.clear)
    }
    
    @ViewBuilder private var deleteButtonWithAlert: some View {
        if #available(iOS 15.0, *) { // If no iOS 15 user will just not see the confirmation dialog but can still delete
            actionButton(action: {
                isPresentingConfirm = true
            }, buttonType: .delete, disabled: $deleteDisabled)
            .confirmationDialog("", isPresented: $isPresentingConfirm) {
                Button(DeleteStrings.areYouSure.localized, role: .destructive) {
                    (viewModel.deleteAction ?? {})()
                }
            } message: {
                Text(DeleteStrings.cannotUndo.localized)
            }
        } else {
            actionButton(action: {
                (viewModel.deleteAction ?? {})()
            }, buttonType: .delete, disabled: $deleteDisabled)
        }
    }
    
    private func actionButton(action: @escaping () -> Void, buttonType: EditableCardButtonType, disabled: Binding<Bool>) -> some View {
        VStack(spacing: 0) {
            Button {
                action()
            } label: {
                buttonType.icon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(buttonType.foregroundColor(colorPalette: colorPalette, disabled: disabled))
                    .frame(width: iconWidth)
                    .padding(iconPadding)
                    .frame(maxHeight: .infinity)
                    .frame(width: buttonWidth)
            }
            .frame(maxHeight: .infinity)
            .frame(width: buttonWidth)
            .background(Color.clear)
        }
    }
}

#if DEBUG
struct EditableCardContainer_Previews: PreviewProvider {
    static var previews: some View {
        EditableCardContainer(
            hasWarning: .constant(false),
            editDisabled: .constant(false),
            deleteDisabled: .constant(false),
            content: {
                Text("Test")
            },
            viewModel: .init(
                container: .preview,
                editAction: {},
                deleteAction: {}))
    }
}
#endif
