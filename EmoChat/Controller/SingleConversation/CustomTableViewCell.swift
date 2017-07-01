//
//  CustomTableViewCell.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit


class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var background: UIImageView!
    
    var delegate: CellDelegate!
    
    var messageEntity: Message {
        get {
            return _messageEntity
        }
        
        set {
            _messageEntity = newValue
            //TODO: check type of content
            message.text = newValue.content!.content
        }
    }
    
    var contentRect: CGRect {
        get {
            return message.frame
        }
    }
    
    func handler(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            delegate.cellDelegate(self, didHandle: .longPress)
        }
    }
    
    private var _messageEntity: Message!
}

// MARK: - Actions

enum Action {
    case longPress
    // Other actions
}

protocol CellDelegate {
    func cellDelegate(_ sender: UITableViewCell, didHandle action: Action)
}

class LeftCell: CustomTableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handler))
        message.addGestureRecognizer(recognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

}

class RightCell: CustomTableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var isReceived = false {
        didSet {
            if isReceived {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                time.isHidden = false
                time.text = messageEntity.time.formatDate()

            } else {
                time.isHidden = true
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()

            }
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
    
}
