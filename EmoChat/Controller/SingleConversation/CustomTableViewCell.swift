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


class LeftCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: SpecialTextView!
    @IBOutlet weak var background: UIImageView!
    
    var messageEntity: Message? {
        didSet {
            message.text = messageEntity!.content!.content
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(test) {
            return true
        }
        return false
    }
    
    func test () {
        print(message.text)
    }

//    override func layoutSubviews() {
//        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress (_:)))
//        self.message?.addGestureRecognizer(longPress)
//        
//        longPress.delegate = self
//        
//    }

    func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            //let location = sender.location(in: sender.view)
            let menuController = UIMenuController.shared
            let item1 = UIMenuItem(title: "Test1", action: #selector(test))
            menuController.menuItems = [item1]
            menuController.update()
            menuController.setTargetRect(CGRect(x: self.message.frame.size.width/2, y: message.frame.origin.y - 10, width: 0.0, height: 0.0), in: self)
            
            menuController.setMenuVisible(true, animated: true)
            
        }
    }
//
//    func copyAction (_ cell: UITableViewCell) {
//        print ("here i am")
//        UIPasteboard.general.string = message.text
//    }
//    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
//    
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(copyAction) {
//            return true
//        }
//        return false
//    }
//    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handler))
        message.addGestureRecognizer(recognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func handler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            sender.view!.becomeFirstResponder()
            let menu = UIMenuController.shared
            menu.setTargetRect(message.frame, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
}

class RightCell: UITableViewCell {
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var message: SpecialTextView!
    
    var isReceived = false {
        didSet {
            if isReceived {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                time.isHidden = false
                time.text = messageEntity?.time.formatDate()

            } else {
                time.isHidden = true
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()

            }
        }
    }
    
    var messageEntity: Message? {
        didSet {
            message.text = messageEntity!.content!.content            
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handler))
        message.addGestureRecognizer(recognizer)
    }
    
      override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func handler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
            sender.view!.becomeFirstResponder()
            let menu = UIMenuController.shared
            menu.setTargetRect(message.frame, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
}
