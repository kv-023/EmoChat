//
//  RestUISingleConversationController.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 30.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation
import UIKit


protocol SingleConversationControllerProtocol: class {

    func resizeSingleConversationCell(cell: SingleConversationUITableViewCell)
}

//MARK:- Controller for RestUI

extension SingleConversationUITableViewCell {

    func parseDataFromMessageText(delaySeconds delay: Int = 0) {

        guard let notNullMessage = self.messageEntity else {
            return
        }

//        self.messageModel = nil

        let newModel = MessageModel(message: notNullMessage)
        newModel.getParseDataFromResource(delaySeconds: delay, completion: {
            (allDone) in


            if allDone {
//                self.messageModel = newModel

                guard newModel.messageURLDataIsReady
                    && newModel.messageURLData.count > 0 else {

                        return
                }

                DispatchQueue.main.async {

                    if self.itIsRightModelWithMessage(model: newModel) {
                        self.messageModel = newModel
                        self.updateUI()
                    }
                }
            }
        })
    }

    private func itIsRightModelWithMessage() -> Bool {

        return self.messageModel?.uid == self.messageEntity?.uid
    }
    private func itIsRightModelWithMessage(model tMessageModel:MessageModel?) -> Bool {

        return tMessageModel?.uid == self.messageEntity?.uid
    }
    private func itIsRightModelWithMessage(modelUID uid:String?) -> Bool {

        return uid == self.messageEntity?.uid
    }

    private func updateUI() {

        guard itIsRightModelWithMessage() else {
            return
        }

        weak var contentViewCell:RestUIInfoView?

        guard let messageURLData = messageModel?.messageURLData else {
            return
        }

        DispatchQueue.main.async  {
            contentViewCell = self.xibToFrameSetup()
            contentViewCell?.spinner.startAnimating()
        }

        let downloadGroup = DispatchGroup()
        var dicTemData: [String: Any?] = [:]

        for (key, value) in messageURLData {

            contentViewCell?.url = key

            if let valueModel = value as? UrlembedModel {

                contentViewCell?.dataModel = valueModel

                let arrayOfURL: [(String,String?)] = [("mainImage", valueModel.url),
                                                       ("urlImageIco", valueModel.favicon)]

                let _ = DispatchQueue.global(qos: .userInitiated)
                DispatchQueue.concurrentPerform(iterations: arrayOfURL.count) { i in
                    let index = Int(i)
                    let (dataField, urlAdress) = arrayOfURL[index]

                    downloadGroup.enter()

                    dicTemData.updateValue(valueModel.title, forKey: "captionLabel")
                    dicTemData.updateValue(valueModel.text, forKey: "detailLabel")

                    if let notNullUrl = urlAdress {
                        JSONParser.sharedInstance.downloadImage(url: notNullUrl) { (image) in

                            dicTemData.updateValue(image, forKey: dataField)
                            downloadGroup.leave()
                        }
                    }
                }
            }

            break // only one cycle needed
        }

        downloadGroup.notify(queue: DispatchQueue.main) { // 2
            DispatchQueue.main.async  {

                contentViewCell?.captionLabel.text = dicTemData["captionLabel"] as? String ?? ""
                contentViewCell?.detailLabel.text = dicTemData["detailLabel"] as? String ?? ""
                contentViewCell?.urlImageIco.image = dicTemData["urlImageIco"] as? UIImage ?? nil
                contentViewCell?.mainImage.image =  dicTemData["mainImage"] as? UIImage ?? nil

                contentViewCell?.spinner.stopAnimating()
            }
        }
    }

    private func xibToFrameSetup() -> RestUIInfoView {

        let contentViewCell = Bundle.main.loadNibNamed("RestUIInfo2",
                                              owner: self.previewContainer,
                                              options: nil)?.first as! RestUIInfoView

        contentViewCell.eraseAllFields()
        contentViewCell.captionLabel.text = "url preview loading ..."

        let ccViewHeight = contentViewCell.bounds.height
        contentViewCell.translatesAutoresizingMaskIntoConstraints = false

        contentViewCell.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.previewContainer.frame.width,
                                       height: ccViewHeight)


        self.heightOfPreviewContainer.constant = ccViewHeight
        self.previewContainer.addSubview(contentViewCell)


        setConstrainInSubView(embeddedView: contentViewCell, parrentView: self.previewContainer)
        self.previewContainer.layoutIfNeeded()


        self.singleConversationControllerDelegate?.resizeSingleConversationCell(cell: self)

        contentViewCell.layer.cornerRadius = 10
        contentViewCell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)

        return contentViewCell
    }

    private func setConstrainInSubView(embeddedView myView: UIView,
                                       parrentView hostView: UIView) {
        let leading = NSLayoutConstraint(item: myView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: hostView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        self.addConstraint(leading)

        let bottom = NSLayoutConstraint(item: myView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: hostView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        self.addConstraint(bottom)

        let trailing = NSLayoutConstraint(item: myView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: hostView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        self.addConstraint(trailing)
        
        let top = NSLayoutConstraint(item: myView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: hostView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        
        self.addConstraint(top)
    }

    func removeRestUIInfoViewFromView(view masterView: UIView) {
        let subviews = masterView.subviews

        for currentSubview in subviews {

            guard currentSubview is RestUIInfoView else {
                continue
            }

            currentSubview.removeFromSuperview()
        }
    }

}
