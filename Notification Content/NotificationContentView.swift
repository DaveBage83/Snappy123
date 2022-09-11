//
//  NotificationContentView.swift
//  Notification Content
//
//  Created by Kevin Palser on 26/08/2022.
//

import SwiftUI

struct NotificationContentView: View {
    
    // MARK: - View model
    @StateObject var viewModel: NotificationContentViewModel
    
    // MARK: - Main view
    var body: some View {
        
        VStack {
            if #available(iOSApplicationExtension 15.0, *) {
                // iOS 15+ approach
                if let url = viewModel.url {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            } else {
                // iOS 14 approach
                if
                    let imageData = viewModel.imageData,
                    let image = UIImage(data: imageData)
                {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
        
    }
    
}

#if DEBUG
struct NotificationContentView_Previews: PreviewProvider {

    static var previews: some View {
        NotificationContentView(
            viewModel: .init()
        )
    }
}
#endif
