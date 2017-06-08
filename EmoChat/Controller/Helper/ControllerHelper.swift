//
//  ControllerHelper.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 07.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UITextField {

    func useUnderline() {
        let border = CALayer()
        let borderWidth = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        
        border.frame = CGRect(x: 0,
                              y: self.frame.size.height - borderWidth,
                              width: self.frame.size.width,
                              height: self.frame.size.height)
        
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }

    func redBorder() {
        self.layer.cornerRadius = 7.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.masksToBounds = true
    }

    func whiteBorder() {
        self.layer.cornerRadius = 7.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.masksToBounds = true
    }
}

extension UILabel {

    func printError(errorText: String) {
        self.textColor = UIColor.red
        self.text = errorText
    }

    func printOK(okText: String) {
        self.textColor = UIColor.white
        self.text = okText
    }
}
