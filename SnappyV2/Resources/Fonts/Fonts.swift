//
//  Fonts.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 29/06/2021.
//

import SwiftUI

public extension Font {
    static let snappyLargeTitle = {
        custom("Montserrat-Regular", size: 34, relativeTo: .title)
    }()

    static let snappyTitle = {
        custom("Montserrat-Regular", size: 28, relativeTo: .title)
    }()
    
    static let snappyTitle2 = {
        custom("Montserrat-Regular", size: 22, relativeTo: .title)
    }()
    
    static let snappyTitle3 = {
        custom("Montserrat-Regular", size: 20, relativeTo: .title)
    }()
    
    static let snappyHeadline = {
        custom("Montserrat-SemiBold", size: 17, relativeTo: .headline)
    }()
    
    static let snappyBody = {
        custom("Montserrat-Regular", size: 16, relativeTo: .body)
    }()
    
    static let snappySubheadline = {
        custom("Montserrat-Regular", size: 15, relativeTo: .subheadline)
    }()
    
    static let snappyFootnote = {
        custom("Montserrat-Regular", size: 13, relativeTo: .footnote)
    }()
    
    static let snappyCaption = {
        custom("Montserrat-Regular", size: 12, relativeTo: .caption)
    }()
    
    static let snappyCaption2 = {
        custom("Montserrat-Regular", size: 11, relativeTo: .caption2)
    }()
    
    static let snappyBadge = {
        custom("Montserrat-SemiBold", size: 11, relativeTo: .headline)
    }()
}

struct Font_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section(header: Text("Large Title")) {
                    Text("Large Title text")
                        .font(.snappyLargeTitle)
                }
                
                Section(header: Text("Title")) {
                    Text("Title text")
                        .font(.snappyTitle)
                }
                
                Section(header: Text("Title 2")) {
                    Text("Title text")
                        .font(.snappyTitle2)
                }
                
                Section(header: Text("Title 3")) {
                    Text("Title text")
                        .font(.snappyTitle3)
                }
                
                Section(header: Text("Headline")) {
                    Text("Headline text")
                        .font(.snappyHeadline)
                }
                
                Section(header: Text("Body")) {
                    Text("Body text")
                        .font(.snappyBody)
                }
                
                Section(header: Text("Subheadline")) {
                    Text("Subheadline text")
                        .font(.snappySubheadline)
                }
                
                Section(header: Text("Footnote")) {
                    Text("Footnote text")
                        .font(.snappyFootnote)
                }
                
                Section(header: Text("Caption 1")) {
                    Text("Caption text")
                        .font(.snappyCaption)
                }
                
                Section(header: Text("Caption 2")) {
                    Text("Caption text")
                        .font(.snappyCaption2)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Snappy Fonts")
        }
        .environment(\.sizeCategory, .large)
    }
}
