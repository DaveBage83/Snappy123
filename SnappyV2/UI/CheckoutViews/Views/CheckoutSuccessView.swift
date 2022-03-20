//
//  CheckoutSuccessView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 28/01/2022.
//

import SwiftUI

class CheckoutSuccessViewModel: ObservableObject {
    let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
}

struct CheckoutSuccessView: View {
    typealias ProgressStrings = Strings.CheckoutView.Progress
    
    @StateObject var viewModel: CheckoutSuccessViewModel
    
    var body: some View {
        ScrollView {
            checkoutProgress()
                .background(Color.white)
            
            successBanner()
                .padding([.top, .leading, .trailing])
            
            OrderSummaryCard(viewModel: .init(container: viewModel.container, order: TestPastOrder.order))
                .padding()

            CreateAccountCard(viewModel: .init(container: viewModel.container))
                .padding(.horizontal)
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
            
            ProgressBarView(value: 4, maxValue: 4, backgroundColor: .snappyBGFields1, foregroundColor: .snappySuccess)
                .frame(height: 6)
                .padding(.horizontal, -3)
        }
    }
    
    func successBanner() -> some View {
        HStack {
            Image("default_banner_advert_placeholder")
                .overlay (
                    HStack {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.snappySuccess)
                            Spacer()
                        }
                        Spacer()
                    }
                )
            
            Text("Your order was successful")
                .font(.snappyTitle2).bold()
                .foregroundColor(.snappySuccess)
        }
    }
}

struct CheckoutSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutSuccessView(viewModel: .init(container: .preview))
            .environmentObject(CheckoutViewModel(container: .preview))
    }
}
