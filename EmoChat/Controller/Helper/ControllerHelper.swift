//
//  ControllerHelper.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 07.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

extension UITextField {

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
