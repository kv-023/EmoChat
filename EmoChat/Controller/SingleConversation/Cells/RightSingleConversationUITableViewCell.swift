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
            text.append(NSAttributedString(string: getTextForCellText(cell: self),
                                           attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.systemFont(ofSize: CGFloat.init(15.0))])))

            message.attributedText = text
            
            setNullableDataInPreviewContainer()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
