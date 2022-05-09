//
//  Fonts.swift
//  SnappyV2Study
//
//  Created by Henrik Gustavii on 29/06/2021.
//

import SwiftUI

public extension Font {
    static let heading1 = {
        custom("Montserrat-ExtraBold", size: 28, relativeTo: .headline)
    }()
    
    static let heading2 = {
        custom("Montserrat-Bold", size: 24, relativeTo: .headline)
    }()
    
    static let heading3 = {
        custom("Montserrat-Bold", size: 20, relativeTo: .headline)
    }
    
    static let heading4 = {
        custom("Montserrat-Bold", size: 16, relativeTo: .headline)
    }
    
    struct Body1 {
        static let regular = {
            custom("Montserrat-Regular", size: 14, relativeTo: .body)
        }
        
        static let semiBold = {
            custom("Montserrat-SemiBold", size: 14, relativeTo: .body)
        }
    }
    
    struct Body2 {
        static let regular = {
            custom("Montserrat-Regular", size: 12, relativeTo: .body)
        }
        
        static let semiBold = {
            custom("Montserrat-SemiBold", size: 12, relativeTo: .body)
        }
    }
    
    struct Caption1 {
        static let semiBold = {
            custom("Montserrat-SemiBold", size: 10, relativeTo: .caption)
        }
        
        static let bold = {
            custom("Montserrat-Bold", size: 10, relativeTo: .caption)
        }
    }
    
    struct Caption2 {
        static let semiBold = {
            custom("Montserrat-SemiBold", size: 8, relativeTo: .caption2)
        }
        
        static let bold = {
            custom("Montserrat-Bold", size: 8, relativeTo: .caption2)
        }
    }
    
    static let button1 = {
        custom("Montserrat-SemiBold", size: 16, relativeTo: .body)
    }
    
    static let button2 = {
        custom("Montserrat-SemiBold", size: 12, relativeTo: .body)
    }
    
    static let button3 = {
        custom("Montserrat-SemiBold", size: 8, relativeTo: .body)
    }
    
    static let hyperlink1 = {
        custom("Montserrat-Regular", size: 14, relativeTo: .body)
    }
    
    static let hyperlink2 = {
        custom("Montserrat-Regular", size: 12, relativeTo: .body)
    }
    
    struct Social {
        struct Facebook {
            static let facebook1 = {
                custom("Helvetica Bold", size: 20, relativeTo: .body)
            }
            
            static let facebook2 = {
                custom("Helvetica Bold", size: 18, relativeTo: .body)
            }
            
            static let facebook3 = {
                custom("Helvetica Bold", size: 16, relativeTo: .body)
            }
        }
        
        struct Google {
            static let google1 = {
                custom("Roboto Medium", size: 20, relativeTo: .body)
            }
            
            static let google2 = {
                custom("Roboto Medium", size: 18, relativeTo: .body)
            }
            
            static let google3 = {
                custom("Roboto Medium", size: 16, relativeTo: .body)
            }
        }
    }
    
    

    #warning("The below will be deprecated once all fonts replaced with the above which come from the designs")
    
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
    
    static let snappyBody2 = {
        custom("Montserrat-Regular", size: 14, relativeTo: .body)
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
                
                Section(header: Text("Body 2")) {
                    Text("Body text")
                        .font(.snappyBody2)
                }
                
                Section(header: Text("Subheadline")) {
                    Text("Subheadline text")
                        .font(.snappySubheadline)
                }
                
                Section(header: Text("Footnote")) {
                    Text("Footnote text")
                        .font(.snappyFootnote)
                }
                
                Group {
                    Section(header: Text("Caption 1")) {
                        Text("Caption text")
                            .font(.snappyCaption)
                    }
                    
                    Section(header: Text("Caption 2")) {
                        Text("Caption text")
                            .font(.snappyCaption2)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Snappy Fonts")
        }
        .environment(\.sizeCategory, .large)
    }
}
