//
//  RirgtSingleConversationUITableViewCell.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 30.06.17.
//  ..refactored class created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class RightCell: CustomTableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
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

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

class RightTextCell: RightCell {
    
    override var messageEntity: Message? {
        didSet {
            //or set media content in ui elements
            let text = NSMutableAttributedString(string: "")
//            text.append(NSAttributedString(string: (messageEntity?.content!.content)!, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: CGFloat.init(15.0))]))
            text.append(NSAttributedString(string: getTextForCellText(cell: self),
                                           attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: CGFloat.init(15.0))]))

            message.attributedText = text
            
            setNullableDataInPreviewContainer()
        }
    }

//    override func getTextForCellText() -> String {
//        return "sent " + super.getTextForCellText()
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}



