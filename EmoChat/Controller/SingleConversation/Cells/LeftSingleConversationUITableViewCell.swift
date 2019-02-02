//
//  LeftSingleConversationUITableViewCell.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 30.06.17.
//  ..refactored class created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

//you can derive from this class for your own left message prototypes
class LeftCell: CustomTableViewCell {
    
    //TODO: displaying sender's name in all left cells
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class LeftTextCell: LeftCell {
    
    var name: NSMutableAttributedString?
    
    override var messageEntity: Message? {
        didSet {
            //or set media content in ui elements
            let text = NSMutableAttributedString(string: "")
            if let enterText = name {
                text.append(enterText)
            }
            text.append(NSAttributedString(string: getTextForCellText(cell: self),
                                           attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: CGFloat.init(15.0))])))

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
