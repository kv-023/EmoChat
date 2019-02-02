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
    @IBOutlet weak var message: SpecialTextView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var heightOfPreviewContainer: NSLayoutConstraint!

    weak var delegate: CellDelegate!
    weak var singleConversationControllerDelegate: SingleConversationControllerProtocol?

    var temporaryCellHeight:CGFloat = 0
    var extraCellHeiht:CGFloat {
        return heightOfPreviewContainer.constant
    }
    var contentTypeOfMessage: MessageContentType {
        return messageEntity?.content?.type ?? .text
    }
    var originTextInCell: String {
        return messageEntity?.content?.content ?? ""
    }

    func showHideAdditionalInfoFromMessageModel() {

        switch  contentTypeOfMessage {
        case .text:
            if let notNullMessageModel = messageModel as? MessageModel {

                if notNullMessageModel.containsUrlLinks {
                    updateUIForMessageModel()
                } else {
                    setNullableDataInPreviewContainer()
                }
            } else {
                let arrayOfLinks = self.getArrayOfRegexMatchesForURLInText(text: self.originTextInCell)

                if arrayOfLinks.count > 0 {
                    //lets show spinner animation
                    showViewForRestUIContent()
                    //get&show data
                    parseDataFromMessageTextForCell()
                } else {
                    setNullableDataInPreviewContainer()
                }

            }
        case .audio:
            let notNullMessageModel = messageModel as? MessageModelAudio

            if notNullMessageModel?.dataForMediaInfoView != nil {

                updateUIForMediaMessageModel()
            } else {
                //lets show spinner animation
                showViewForContent()
                //get&show data
                getMediaContentFromMessageTextForCell()
            }

        default:
            break
        }
    }

    weak var messageModel: MessageModelGeneric? // don't use observers like DidSet.. - it can init memory leaks!!

    //SHOULD BE OVERRIDDEN IN SUBCLASSES FOR DIFFERENT CONTENT TYPE
    var messageEntity: Message? {
        didSet {
            setNullableDataInPreviewContainer()
        }
    }

    func parseDataFromMessageTextForCell() {
        parseDataFromMessageText(delaySeconds: 1)
    }

    func getMediaContentFromMessageTextForCell() {
        getMediaContentFromMessageText(delaySeconds: 1)
    }

    //CAN BE OVERRIDDEN
    var contentRect: CGRect {
        get {
            return self.background.frame
        }
    }

    @objc func handler(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            delegate.cellDelegate(self, didHandle: .longPress)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setInitDataForUI()
    }

    private func setInitDataForUI() {
        addRecognizerForMessage()

        previewContainer.backgroundColor = UIColor.clear
        setNullableHeightOfPreviewContainer()
    }

    func setNullableDataInPreviewContainer() {
        removeViewFromSuperView(view: previewContainer)
        setNullableHeightOfPreviewContainer()
    }

    func setNullableHeightOfPreviewContainer() {
        if contentTypeOfMessage != .audio {
            heightOfPreviewContainer.constant = 0
        }
    }

    //SHOULD BE OVERRIDDEN TO CHANGE SOURCE FOR TAP RECOGNIZER
    func addRecognizerForMessage() {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handler))
        message.addGestureRecognizer(recognizer)
    }

    func getTextForCellText(cell: UITableViewCell) -> String {
        var valueForReturn: String = ""

        switch contentTypeOfMessage {
        case .text:
            valueForReturn = originTextInCell
            valueForReturn.shrinkUrlAddress()
        case .audio, .video, .photo:

            var theAddedText:String = ""
            if cell is LeftCell {
                theAddedText = "📨"
            } else if cell is RightCell {
                theAddedText =  "✉️"
            }

            valueForReturn = theAddedText + contentTypeOfMessage.rawValue
        }

        return valueForReturn
    }
}

// MARK: - Actions

enum Action {
    case longPress
    // Other actions
}

protocol CellDelegate: class {
    func cellDelegate(_ sender: UITableViewCell, didHandle action: Action)
}

//MARK:- RegexCheckProtocol ext.
extension CustomTableViewCell: RegexCheckProtocol {
    
}


