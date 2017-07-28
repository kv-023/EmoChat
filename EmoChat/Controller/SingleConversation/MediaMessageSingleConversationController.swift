//
//  RestUISingleConversationController.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 28.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation
import UIKit


//MARK:- Controller for RestUI

extension CustomTableViewCell {

//    func parseDataFromMessageText(delaySeconds delay: Int = 0) {
//
//        guard let notNullMessage = self.messageEntity else {
//            return
//        }
//
//        let newModel = MessageModel(message: notNullMessage)
//        newModel.getParseDataFromResource(delaySeconds: delay, completion: { //[unowned self]
//            (allDone) in
//
//            if allDone {
//                guard newModel.messageURLDataIsReady
//                    && newModel.messageURLData.count > 0 else {
//                        return
//                }
//
//                DispatchQueue.main.async {
//                    if self.itIsRightModelWithMessage(model: newModel) {
//                        self.singleConversationControllerDelegate?.addMessageModelInSingleConversationDictionary(message: notNullMessage,                                                                                                    model: newModel)
//                        self.messageModel = newModel
//
//                        //self.updateUI()
//                        self.updateUIForMessageModel()
//                    }
//                }
//            }
//        })
//    }

    var extraViewXibName: String {
        get {
            switch contentTypeOfMessage {
            case .audio:
                return "AudioMessageView"
            case .text:
                return "RestUIInfo2"
            case .photo, .video:
                return "NEED-TO-REWRITE"
            default:
                return "RestUIInfo2"
            }
        }
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
//    public func updateUIForMessageModel() {
//        if !Thread.isMainThread {
//            DispatchQueue.main.async {
//                self.updateUI()
//            }
//        } else {
//            self.updateUI()
//        }
//    }

    func showViewForContent() {

        // weak var contentViewCell:RestUIInfoView?
        let contentViewCell = getContentViewCell()
        contentViewCell?.spinner.startAnimating()
    }

    func getContentViewCell<T: UIView>() -> T? {
        var contentViewCell:T?

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

//    private func updateUI() {
//
//        guard itIsRightModelWithMessage() else {
//            return
//        }
//
//        weak var contentViewCell:RestUIInfoView?
//
//        guard let messageURLData = messageModel?.messageURLData else {
//            return
//        }
//
//        contentViewCell = getContentViewCell()
//
//        DispatchQueue.main.async  {
//            contentViewCell?.spinner.startAnimating()
//        }
//
//        if let notNullDataForRestUIInfoView = self.messageModel?.dataForRestUIInfoView  {
//            DispatchQueue.main.async {
//                contentViewCell?.fullFillViewFromDataInfo(data: notNullDataForRestUIInfoView)
//                contentViewCell?.spinner.stopAnimating()
//            }
//        } else {
//
//            let downloadGroup = DispatchGroup()
//            var dicTemData: [String: Any?] = [:]
//
//            for (key, value) in messageURLData {
//
//                dicTemData.updateValue(key, forKey: "url")
//
//                if let valueModel = value as? UrlembedModel {
//
//                    contentViewCell?.dataModel = valueModel
//
//                    let arrayOfURL: [(String,String?)] = [("mainImage", valueModel.url),
//                                                          ("urlImageIco", valueModel.favicon)]
//
//                    let _ = DispatchQueue.global(qos: .userInitiated)
//                    DispatchQueue.concurrentPerform(iterations: arrayOfURL.count) { i in
//                        let index = Int(i)
//                        let (dataField, urlAdress) = arrayOfURL[index]
//
//                        downloadGroup.enter()
//
//                        dicTemData.updateValue(valueModel.title, forKey: "captionLabel")
//                        dicTemData.updateValue(valueModel.text, forKey: "detailLabel")
//
//                        if let notNullUrl = urlAdress,
//                            notNullUrl.characters.count > 0 {
//                            JSONParser.sharedInstance.downloadImage(url: notNullUrl) { (image) in
//
//                                var imageForCell = image
//
//                                //resize it
//                                if let notNullImage = imageForCell {
//                                    let rectValue:CGFloat = 50
//                                    if (notNullImage.size.height > rectValue || notNullImage.size.width > rectValue) == true {
//                                        imageForCell = notNullImage.resizeImageWith(newSize:
//                                            CGSize(width: rectValue, height: rectValue))
//                                    }
//                                }
//
//                                dicTemData.updateValue(imageForCell, forKey: dataField)
//                                downloadGroup.leave()
//                            }
//                        } else {
//                            downloadGroup.leave()
//                        }
//                    }
//                }
//
//                break // only one cycle needed
//            }
//
//            downloadGroup.notify(queue: DispatchQueue.main) { // 2
//                DispatchQueue.main.async  {
//
//                    let tempParsedData = DataForRestUIInfoView(dict: dicTemData)
//                    contentViewCell?.dataForRestUIInfoView = tempParsedData
//                    self.messageModel?.dataForRestUIInfoView = tempParsedData
//                    contentViewCell?.spinner.stopAnimating()
//                }
//            }
//        }
//
//    }

    //MARK:- UIView creation
    private func getPrepareXibOfEmbeddedView<Tview: UIView>(eraseExtraViews: Bool = true,
                                             xibName: String? = nil) -> Tview? {
        guard let masterContainer = self.previewContainer else {
            return nil
        }

        let xibNameForLoad = xibName ?? extraViewXibName

        //var arrayOfViews = getRestUIInfoViewFromView(view: masterContainer)
        var arrayOfViews:[Tview] = getRequestedViewFromView(view: masterContainer)

        let countOfViews = arrayOfViews.count
        if countOfViews > 0 {

            let viewForReturn = arrayOfViews[0]
            //prepare part
            if let notNullIndexOfElement = arrayOfViews.index(of: viewForReturn) {
                arrayOfViews.remove(at: notNullIndexOfElement)
            }

            if countOfViews > 1 && eraseExtraViews {
                removeRequestedViewFromView(view: masterContainer,
                                             arrayOfRequestedViews: &arrayOfViews)
            }

            //let ccViewHeight = calculateHeightOfView(view: viewForReturn)
            //setPreviewContainerHeight(height: viewForReturn.heightOriginal)
            self.previewContainer.layoutIfNeeded()
            //self.singleConversationControllerDelegate?.resizeSingleConversationCell(cell: self)

            return viewForReturn
        } else {
            let viewForReturn:Tview = xibToFrameSetup(xibName: xibNameForLoad)
            return viewForReturn
        }
    }

//    func setPreviewContainerHeight(height: CGFloat) {
//        self.heightOfPreviewContainer.constant = height
//    }

    private func xibToFrameSetup<Tview: UIView>(xibName: String) -> Tview {

        let contentViewCell = Bundle.main.loadNibNamed(xibName,
                                                       owner: self.previewContainer,
                                                       options: nil)?.first as! Tview

//        contentViewCell.eraseAllFields()
//        contentViewCell.captionLabel.text = NSLocalizedString("loading ...", comment: "")

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
//        contentViewCell.mainImage.layer.cornerRadius = radiuR
//        contentViewCell.mainImage.layer.masksToBounds = true
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

//    func removeRestUIInfoViewFromView(view masterView: UIView) {
//        let subviews = masterView.subviews
//
//        for currentSubview in subviews {
//
//            guard currentSubview is RestUIInfoView else {
//                continue
//            }
//
//            currentSubview.removeFromSuperview()
//        }
//    }
    func removeRequestedViewFromView<Tview>(view masterView: UIView, typeOfRequestedView: Tview.Type) {
        let subviews = masterView.subviews

        for currentSubview in subviews {

            guard currentSubview is Tview else {
                continue
            }

            currentSubview.removeFromSuperview()
        }
    }

    func removeRequestedViewFromView<Tview: UIView>(view masterView: UIView,
                                      arrayOfRequestedViews: inout [Tview]) {

        for currentSubview in arrayOfRequestedViews {
            if let notNullIndexOfElement = arrayOfRequestedViews.index(of: currentSubview) {
                arrayOfRequestedViews.remove(at: notNullIndexOfElement)
            }
            
            currentSubview.removeFromSuperview()
        }
    }   

//    func getRestUIInfoViewFromView(view masterView: UIView) -> Array<RestUIInfoView> {
//        let subviews = masterView.subviews
//        
//        var arrayForReturn: Array<RestUIInfoView> = []
//        for currentSubview in subviews {
//            
//            if let currentMySubview: RestUIInfoView = currentSubview as? RestUIInfoView {
//                arrayForReturn.append(currentMySubview)
//            }
//        }
//        
//        return arrayForReturn
//    }

    func getRequestedViewFromView<Tview>(view masterView: UIView) -> Array<Tview> {
        let subviews = masterView.subviews
        
        var arrayForReturn: Array<Tview> = []
        for currentSubview in subviews {
            
            if let currentMySubview: Tview = currentSubview as? Tview {
                arrayForReturn.append(currentMySubview)
            }
        }
        
        return arrayForReturn
    }
}
