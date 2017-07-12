//
//  UITextViewFixed.swift
//  Page
//
//  Created by 倪卫国 on 09/07/2017.
//  Copyright © 2017 Oliver Zhang. All rights reserved.
//

import UIKit

// Remove NSTextContainer gap
// See: https://stackoverflow.com/questions/746670/how-to-lose-margin-padding-in-uitextview
@IBDesignable
class UITextViewFixed: UITextView {

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 14
    }

}
