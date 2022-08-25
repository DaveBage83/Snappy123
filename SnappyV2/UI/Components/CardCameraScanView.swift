//
//  CardCameraScanView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 22/08/2022.
//

import SwiftUI

struct CardCameraScanView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SharkCardScanViewController
    var action: (String?, String?, String?) -> ()
    
    func makeUIViewController(context: Context) -> SharkCardScanViewController {
        let scannerVC = SharkCardScanViewController(viewModel: .init(successHandler: { (response) in
            action(response.holder, response.number, response.expiry)
        }))
        return scannerVC
    }
    
    func updateUIViewController(_ uiViewController: SharkCardScanViewController, context: Context) {}
}
