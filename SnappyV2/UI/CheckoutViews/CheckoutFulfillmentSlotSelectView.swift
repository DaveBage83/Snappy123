//
//  CheckoutFulfillmentSlotSelectView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

class CheckoutFulfillmentSlotSelectViewModel: ObservableObject {
    
}

struct CheckoutFulfillmentSlotSelectView: View {
    typealias ProgressStrings = Strings.CheckoutView.Progress
    typealias LoginStrings = Strings.General.Login
    
    @StateObject var viewModel = CheckoutFulfillmentSlotSelectViewModel()
    @EnvironmentObject var checkoutViewModel: CheckoutViewModel
    
    var body: some View {
        ScrollView {
            checkoutProgress()
                .background(Color.white)
            
            fulfillmentSlotSelect()
                .padding([.top, .leading, .trailing])
            
            continueButton()
                .padding([.top, .leading, .trailing])
        }
    }
    
    // MARK: View Components
    func checkoutProgress() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image.Checkout.car
                    .font(.title2)
                    .foregroundColor(.snappyBlue)
                    .padding()
                
                VStack(alignment: .leading) {
                    Text(ProgressStrings.time.localized)
                        .font(.snappyCaption)
                        .foregroundColor(.gray)
                    
                    #warning("To replace with actual order time")
                    Text("Sun, 15 October, 10:30").bold()
                        .font(.snappyCaption)
                        .foregroundColor(.snappyBlue)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(ProgressStrings.orderTotal.localized)
                        .foregroundColor(.gray)
                    
                    HStack {
                    #warning("To replace with actual order value")
                        Text("£8.95")
                            .fontWeight(.semibold)
                            .foregroundColor(.snappyBlue)
                        
                        Image.General.bulletList
                            .foregroundColor(.snappyBlue)
                    }
                }
                .font(.snappyCaption)
                
            }
            .padding(.horizontal)
            
            ProgressBarView(value: 1, maxValue: 4, backgroundColor: .snappyBGFields1, foregroundColor: .snappyBlue)
                .frame(height: 6)
                .padding(.horizontal, -3)
        }
    }
    
    func fulfillmentSlotSelect() -> some View {
        VStack(alignment: .leading) {
            Text("Fulfillment View here")
                .font(.snappyHeadline)
            
        }
    }
    
    func continueButton() -> some View {
        Button(action: {}) {
            Text("Continue")
                .font(.snappyTitle2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(10)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.snappyTeal)
                )
        }
    }
}

struct CheckoutFulfillmentSlotSelectView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutFulfillmentSlotSelectView()
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
