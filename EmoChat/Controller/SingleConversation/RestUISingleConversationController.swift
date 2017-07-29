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

    func resizeSingleConversationCell(cell: CustomTableViewCell)
    func addMessageModelInSingleConversationDictionary(message: Message, model: MessageModel?)
}

//MARK:- Controller for RestUI

extension CustomTableViewCell {

    func parseDataFromMessageText(delaySeconds delay: Int = 0) {

        guard let notNullMessage = self.messageEntity else {
            return
        }

        let newModel = MessageModel(message: notNullMessage)
        newModel.getParseDataFromResource(delaySeconds: delay, completion: { //[unowned self]
            (allDone) in

            if allDone {
                guard newModel.messageURLDataIsReady
                    && newModel.messageURLData.count > 0 else {
                        return
                }

                DispatchQueue.main.async {
                    if self.itIsRightModelWithMessage(model: newModel) {
                        self.singleConversationControllerDelegate?.addMessageModelInSingleConversationDictionary(message: notNullMessage,                                                                                                    model: newModel)
                        self.messageModel = newModel

                        //self.updateUI()
                        self.updateUIForMessageModel()
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

    //MARK: load detail & update UI
    public func updateUIForMessageModel() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.updateUI()
            }
        } else {
            self.updateUI()
        }
    }

    func showViewForRestUIContent() {

        // weak var contentViewCell:RestUIInfoView?
        let contentViewCell = getContentViewCell()//self.getPrepareXibOfEmbeddedView()
        contentViewCell?.spinner.startAnimating()
    }

    func getContentViewCell() -> RestUIInfoView? {
        var contentViewCell:RestUIInfoView?

        let tasksGroup = DispatchGroup()
        tasksGroup.enter()
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                contentViewCell = self.getPrepareXibOfEmbeddedView()
                tasksGroup.leave()
            }
        } else {
            contentViewCell = self.getPrepareXibOfEmbeddedView()
            tasksGroup.leave()
        }

        tasksGroup.wait()
        return contentViewCell
    }

    private func updateUI() {

        guard itIsRightModelWithMessage() else {
            return
        }

        weak var contentViewCell:RestUIInfoView?

        guard let messageURLData = messageModel?.messageURLData else {
            return
        }

        contentViewCell = getContentViewCell()

        DispatchQueue.main.async  {
            contentViewCell?.spinner.startAnimating()
        }

        if let notNullDataForRestUIInfoView = self.messageModel?.dataForRestUIInfoView  {
            DispatchQueue.main.async {
                contentViewCell?.fullFillViewFromDataInfo(data: notNullDataForRestUIInfoView)
                contentViewCell?.spinner.stopAnimating()
            }
        } else {

            let downloadGroup = DispatchGroup()
            var dicTemData: [String: Any?] = [:]

            for (key, value) in messageURLData {

                dicTemData.updateValue(key, forKey: "url")

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

                        if let notNullUrl = urlAdress,
                            notNullUrl.characters.count > 0 {
                            JSONParser.sharedInstance.downloadImage(url: notNullUrl) { (image) in

                                var imageForCell = image

                                //resize it
                                if let notNullImage = imageForCell {
                                    let rectValue:CGFloat = 50
                                    if (notNullImage.size.height > rectValue || notNullImage.size.width > rectValue) == true {
                                        imageForCell = notNullImage.resizeImageWith(newSize:
                                            CGSize(width: rectValue, height: rectValue))
                                    }
                                }

                                dicTemData.updateValue(imageForCell, forKey: dataField)
                                downloadGroup.leave()
                            }
                        } else {
                            downloadGroup.leave()
                        }
                    }
                }

                break // only one cycle needed
            }

            downloadGroup.notify(queue: DispatchQueue.main) { // 2
                DispatchQueue.main.async  {

                    let tempParsedData = DataForRestUIInfoView(dict: dicTemData)
                    contentViewCell?.dataForRestUIInfoView = tempParsedData
                    self.messageModel?.dataForRestUIInfoView = tempParsedData
                    contentViewCell?.spinner.stopAnimating()
                }
            }
        }

    }

    //MARK:- UIView creation
    private func getPrepareXibOfEmbeddedView(eraseExtraViews: Bool = true) -> RestUIInfoView? {
        guard let masterContainer = self.previewContainer else {
            return nil
        }

        let tryToReloadView:Bool = false //maybe, later it can be useful
        if tryToReloadView {
            var arrayOfViews = getRestUIInfoViewFromView(view: masterContainer)

            let countOfViews = arrayOfViews.count
            if countOfViews > 0 {

                let viewForReturn = arrayOfViews[0]
                //prepare part
                if let notNullIndexOfElement = arrayOfViews.index(of: viewForReturn) {
                    arrayOfViews.remove(at: notNullIndexOfElement)
                }

                if countOfViews > 1 && eraseExtraViews {
                    removeRestUIInfoViewFromView(view: masterContainer,
                                                 arrayOfRequestedViews: &arrayOfViews)
                }

                //let ccViewHeight = calculateHeightOfView(view: viewForReturn)
                //setPreviewContainerHeight(height: viewForReturn.heightOriginal)
                self.previewContainer.layoutIfNeeded()
                //self.singleConversationControllerDelegate?.resizeSingleConversationCell(cell: self)

                return viewForReturn
            } else {

                return xibToFrameSetup()
            }

        } else {
            removeViewFromSuperView(view: masterContainer)
            return xibToFrameSetup()

        }
    }

    func setPreviewContainerHeight(height: CGFloat) {
        self.heightOfPreviewContainer.constant = height
    }

    private func xibToFrameSetup() -> RestUIInfoView {

        let contentViewCell = Bundle.main.loadNibNamed("RestUIInfo2",
                                                       owner: self.previewContainer,
                                                       options: nil)?.first as! RestUIInfoView

        contentViewCell.eraseAllFields()
        contentViewCell.captionLabel.text = NSLocalizedString("loading ...", comment: "")

        let ccViewHeight = contentViewCell.bounds.height
        contentViewCell.translatesAutoresizingMaskIntoConstraints = false

        contentViewCell.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.previewContainer.frame.width,
                                       height: ccViewHeight)

        setPreviewContainerHeight(height: ccViewHeight)

        self.previewContainer.addSubview(contentViewCell)

        setConstrainInSubView(embeddedView: contentViewCell, parrentView: self.previewContainer)
        self.previewContainer.layoutIfNeeded()

        self.singleConversationControllerDelegate?.resizeSingleConversationCell(cell: self)

        let radiuR:CGFloat = 10
        self.previewContainer.layer.cornerRadius = radiuR
        contentViewCell.layer.cornerRadius = radiuR
        contentViewCell.mainImage.layer.cornerRadius = radiuR
        contentViewCell.mainImage.layer.masksToBounds = true
        contentViewCell.layer.masksToBounds = true

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
    func removeRestUIInfoViewFromView(view masterView: UIView,
                                      arrayOfRequestedViews: inout [RestUIInfoView]) {

        for currentSubview in arrayOfRequestedViews {
            if let notNullIndexOfElement = arrayOfRequestedViews.index(of: currentSubview) {
                arrayOfRequestedViews.remove(at: notNullIndexOfElement)
            }
            
            currentSubview.removeFromSuperview()
        }
    }   
    
    
    func getRestUIInfoViewFromView(view masterView: UIView) -> Array<RestUIInfoView> {
        let subviews = masterView.subviews
        
        var arrayForReturn: Array<RestUIInfoView> = []
        for currentSubview in subviews {
            
            if let currentMySubview: RestUIInfoView = currentSubview as? RestUIInfoView {
                arrayForReturn.append(currentMySubview)
            }
        }
        
        return arrayForReturn
    }
}
