//
//  CustomTableViewCell.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class SpecialTextView: UITextView, UITextViewDelegate {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(copy(_:)):
            return true
        case #selector(delete(_:)):
            return true
        default:
            return false
        }
    }
    
    override func copy(_ sender: Any?) {
        print("Copy")
    }
    
    override func delete(_ sender: Any?) {
        print("Delete")
    }
}
