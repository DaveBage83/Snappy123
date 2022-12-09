//
//  BasicUIActionHandler.swift
//  Store
//
//  Created by Dominic Campbell on 02/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import UIKit

final class BasicUIActionHandler: NSObject {
    public var action: (() -> Void)?
    @objc public func performAction() {
        action?()
    }
}

extension UIControl {
    var touchUpInside: BasicUIActionHandler {
        associatedObject {
            BasicUIActionHandler().with {
                addTarget($0, action: #selector(BasicUIActionHandler.performAction), for: .touchUpInside)
            }
        }
    }
    
    var valueChanged: BasicUIActionHandler {
        associatedObject {
            BasicUIActionHandler().with {
                addTarget($0, action: #selector(BasicUIActionHandler.performAction), for: .valueChanged)
            }
        }
    }
}

extension UIGestureRecognizer {
    var handler: BasicUIActionHandler {
        associatedObject {
            BasicUIActionHandler().with {
                self.addTarget($0, action: #selector(BasicUIActionHandler.performAction))
            }
        }
    }
}

extension UIBarButtonItem {
    var handler: BasicUIActionHandler {
        associatedObject {
            BasicUIActionHandler().with {
                self.target = $0
                self.action = #selector(BasicUIActionHandler.performAction)
            }
        }
    }
}
