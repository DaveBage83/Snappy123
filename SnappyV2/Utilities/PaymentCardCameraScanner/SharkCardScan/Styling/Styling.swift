//
//  File.swift
//  
//
//  Created by Lee Burrows on 03/05/2021.
//

import UIKit

typealias LabelStyling = (font: UIFont, color: UIColor)

protocol CardScanStyling {
    var instructionLabelStyling: LabelStyling { get set }
    var cardNumberLabelStyling: LabelStyling { get set }
    var expiryLabelStyling: LabelStyling { get set }
    var holderLabelStyling: LabelStyling { get set }
    var backgroundColor: UIColor { get set }
}

struct DefaultStyling: CardScanStyling {
    var instructionLabelStyling: LabelStyling = (font: UIFont.boldSystemFont(ofSize: 14), color: .black)
    var cardNumberLabelStyling: LabelStyling = (font: UIFont.systemFont(ofSize: 28), color: .white)
    var expiryLabelStyling: LabelStyling = (font: UIFont.systemFont(ofSize: 14), color: .white)
    var holderLabelStyling: LabelStyling = (font: UIFont.systemFont(ofSize: 14), color: .white)
    var backgroundColor: UIColor = .white
    
    init () { }
}
