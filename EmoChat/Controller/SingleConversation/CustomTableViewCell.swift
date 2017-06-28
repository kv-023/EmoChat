//
//  CustomTableViewCell.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class LeftCell: UITableViewCell {

    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var background: UIImageView!
    
    var messageEntity: Message? {
        didSet {
            message.text = messageEntity!.content!.content
        }
    }

    override func layoutSubviews() {
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress (_:)))
        self.message?.addGestureRecognizer(longPress)
        
    }

    func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            //let location = sender.location(in: sender.view)
            let menuController = UIMenuController.shared
            let item = UIMenuItem(title: "Item", action: #selector(actionItem1))
            menuController.menuItems = [item]
            menuController.setTargetRect(CGRect(x: self.message.frame.size.width/2, y: message.frame.origin.y - 10, width: 0.0, height: 0.0), in: sender.view!)
            menuController.setMenuVisible(true, animated: true)
            
        }
    }
    
    func actionItem1 () {
        print("it works")
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(actionItem1) {
            return true
        }
        return false
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class RightCell: UITableViewCell {
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var message: UITextView!
    
    var isReceived = false {
        didSet {
            if isReceived {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                time.isHidden = false
                //time.text = messageEntity?.time

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
    
    override func layoutSubviews() {
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress (_:)))
        self.message?.addGestureRecognizer(longPress)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            //let location = sender.location(in: sender.view)
            let menuController = UIMenuController.shared
            let item = UIMenuItem(title: "Item", action: #selector(actionItem1))
            menuController.menuItems = [item]
            menuController.setTargetRect(CGRect(x: self.message.frame.size.width/2, y: message.frame.origin.y - 10, width: 0.0, height: 0.0), in: sender.view!)
            menuController.setMenuVisible(true, animated: true)
            
        }
    }
    
    func actionItem1 () {
        print("it works")
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(actionItem1) {
            return true
        }
        return false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
