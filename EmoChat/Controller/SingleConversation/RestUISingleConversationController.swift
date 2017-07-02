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

    func resizeSingleConversationCell(cell: UITableViewCell)
}

//MARK:- Controller for RestUI

extension SingleConversationUITableViewCell {

    func parseDataFromMessageText() {
        let notNullDataCell = self
        guard let notNullMessage = notNullDataCell.messageEntity else {
            return
        }

        notNullDataCell.messageModel = nil

        let newModel = MessageModel(message: notNullMessage)
        newModel.getParseDataFromResource { (allDone) in

            if allDone {
                notNullDataCell.messageModel = newModel

                guard newModel.messageURLDataIsReady
                    && newModel.messageURLData.count > 0 else {

                        return
                }

                DispatchQueue.main.async {
                    
                    self.messageModel = newModel
                    
                    self.updateUI()
                }
            }
        }
    }


    private func updateUI() {
//        spinner.startAnimating()

        //        defer {
        //            spinner.stopAnimating()
        //        }

        let downloadGroup = DispatchGroup()

        guard let messageURLData = messageModel?.messageURLData else {
            return
        }

        for (key, value) in messageURLData {
            downloadGroup.enter()

//            myLabel.text = key

            if let valueModel = value as? UrlembedModel {
//                titleLabel.text = valueModel.title

                guard let notNullUrl = valueModel.url else {
                    continue
                }

                JSONParser.sharedInstance.downloadImage(url: notNullUrl) { (image) in
                    DispatchQueue.main.async  {
//                        self.myImageInCell.image = image
                    }

                    downloadGroup.leave()
                }
            }
        }

        downloadGroup.notify(queue: DispatchQueue.main) { // 2
            DispatchQueue.main.async  {
                self.xibToFrameSetup()

//                self.spinner.stopAnimating()
            }
        }
    }


    private func xibToFrameSetup() {

        let contentViewCell = Bundle.main.loadNibNamed("RestUIInfo2",
                                              owner: self,
                                              options: nil)?.first as! RestUIInfoView

        //INITIAL DATA SET

//        contentViewCell.captionLabel.text = "caption dsdsdsd "
//        contentViewCell.detailLabel.text = "detail dsadsdd"
//        contentViewCell.urlImageIco.image = UIImage(named: "mail-sent")

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

}
