//
//  UIStackView.swift
//  
//
//  Created by Russell Warwick on 01/05/2021.
//

import UIKit

extension UIStackView {
    func addArrangedSubViews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
}
