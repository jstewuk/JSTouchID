//
//  UIView+.swift
//  JSTouchID
//
//  Created by Jim on 4/25/16.
//  Copyright © 2016 Jim. All rights reserved.
//

import UIKit

extension UIView {
    class func animateConstraint(view: UIView) {
        self.animateWithDuration(
            0.25, delay: 0.0,
            options: .CurveEaseInOut,
            animations: {
                view.layoutIfNeeded()
            },
            completion: nil)
    }
}
