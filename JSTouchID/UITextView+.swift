//
//  UITextView+.swift
//  JSTouchID
//
//  Created by Jim on 4/25/16.
//  Copyright © 2016 Jim. All rights reserved.
//

import UIKit

extension UITextView {
    
    func configure() {
        self.editable = false
        self.layer.borderColor = UIColor.blueColor().CGColor
        self.layer.borderWidth = 2.0
    }
    
    
    func log(string: String) {
        let _text = text ?? ""
        text = _text + "\n" + string + "\n"
        guard let viewText = text else {return}
        let range = NSMakeRange((viewText as NSString).length - 1, 1)
        self.scrollRangeToVisible(range)
    }
}
