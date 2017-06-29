//
//  CustomTableViewCell.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

//class SpecialTextView: UITextView, UITextViewDelegate {
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        switch action {
//        case #selector(copy(_:)):
//            return true
//        case #selector(delete(_:)):
//            return true
//        default:
//            return false
//        }
//    }
//    
//    override func copy(_ sender: Any?) {
//        UIPasteboard.general.setValue(self.text, forPasteboardType: "TEXT")
//    }
//    
//    override func delete(_ sender: Any?) {
//        let manager = ManagerFirebase.shared
//        
//    }
//}

protocol tableDelegate {
    func tableDelegate(_ sender: UITableViewCell, withRecognizer recognizer: UILongPressGestureRecognizer)
}

class LeftCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var background: UIImageView!
    
    var delegate: tableDelegate!
    
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
        if sender.state == UIGestureRecognizerState.began {
            delegate.tableDelegate(self, withRecognizer: sender)
        }
    }
}

class RightCell: UITableViewCell {
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var message: UITextView!
    
    var delegate: tableDelegate!
    
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
        if sender.state == UIGestureRecognizerState.began {
            delegate.tableDelegate(self, withRecognizer: sender)
        }
    }
}
