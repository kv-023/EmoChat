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

//    static var backGroundColorOfExtraView = UIColor.lightGray.withAlphaComponent(0.3)

    func getMediaContentFromMessageText(delaySeconds delay: Int = 0) {

        guard let notNullMessage = self.messageEntity else {
            return
        }

        let newModel = MessageModelAudio(message: notNullMessage)
        newModel.getParseDataFromResource(delaySeconds: delay, completion: { //[unowned self]
            (allDone) in

            if allDone {

                DispatchQueue.main.async {
                    if self.itIsRightModelWithMessage(model: newModel) {
                        self.singleConversationControllerDelegate?.addMessageModelInSingleConversationDictionary(message: notNullMessage,                                                                                                    model: newModel)
                        self.messageModel = newModel

                        //self.updateUI()
                        self.updateUIForMediaMessageModel()
                    }
                }
            }
        })
    }

    typealias ExtraView = AdditionalCellView

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
    private func itIsRightModelWithMessage(model tMessageModel:MessageModelGeneric?) -> Bool {
        return tMessageModel?.uid == self.messageEntity?.uid
    }
    private func itIsRightModelWithMessage(modelUID uid:String?) -> Bool {
        return uid == self.messageEntity?.uid
    }

//    //MARK: load detail & update UI
    public func updateUIForMediaMessageModel() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.updateUI(viewType: self.getTypeOfCurrenContent())
            }
        } else {
            self.updateUI(viewType: getTypeOfCurrenContent())
        }
    }

    private func getTypeOfCurrenContent() -> AdditionalCellView.Type? {
        var valueForReturn: AdditionalCellView.Type? = nil

        switch contentTypeOfMessage {
        case .audio:
            valueForReturn = AudioMessageView.self
        case .text:
            valueForReturn = RestUIInfoView.self
        //case .photo, .video:
        default:
            break
        }

        return valueForReturn
    }

    func showViewForContent() {
//        switch contentTypeOfMessage {
//        case .audio:
//            showViewForContent1(viewType: AudioMessageView.self)
//        case .text:
//            showViewForContent1(viewType: RestUIInfoView.self)
//            //                case .photo, .video:
//        //                    return UIView
//        default:
//            break
//        }
        showViewForContent1(viewType: getTypeOfCurrenContent())
    }

    func showViewForContent1<Tview: ExtraView>(viewType: Tview.Type?) {

        guard viewType != nil else {
            print("unknown type in func. showViewForContent !!")
            return
        }

        // weak var contentViewCell:RestUIInfoView?
        let contentViewCell:Tview? = getContentViewCell()
        contentViewCell?.spinner.startAnimating()
        contentViewCell?.captionLabel?.text = NSLocalizedString("loading ...", comment: "")//NSLocalizedString("loading ... \(Int(arc4random_uniform(UInt32(240))))", comment: "")
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

    private func updateUI<Tview: ExtraView>(viewType: Tview.Type?) {

        guard viewType != nil else {
            print("unknown type in func updateUI !!")
            return
        }
        guard itIsRightModelWithMessage() else {
            return
        }
//        guard let currentCastedMessageModel = self.messageModel as? Tview? else {
//            print ("An error occured durring casted messsage model to type: \(String(describing: viewType))")
//            return
//        }

        weak var contentViewCell:Tview?

//        guard let messageURLData = messageModel?.messageURLData else {
//            return
//        }
//
        contentViewCell = getContentViewCell()

        DispatchQueue.main.async  {
            contentViewCell?.spinner.startAnimating()
        }

        if let notNullDataForMediaInfoView = self.messageModel?.dataForMediaInfoView  {
            DispatchQueue.main.async {
                contentViewCell?.fullFillViewFromDataInfo(data: notNullDataForMediaInfoView)
                contentViewCell?.spinner.stopAnimating()
            }
        } else {


            let downloadGroup = DispatchGroup()
            var dicTemData: [String: Any?] = [:]

            dicTemData.updateValue("", forKey: "captionLabel")

            let remoteUrl: String? = self.messageModel?.message?.content.content
            dicTemData.updateValue(remoteUrl, forKey: "rurl")

            if let notNullUrl = remoteUrl {
                downloadGroup.enter()
                //
                let nameOfFile = getMediaFileNameFromURL(text: notNullUrl)
                JSONParser.sharedInstance.downloadMediaFromURL(url: notNullUrl,
                                                               newFileName: nameOfFile,
                                                               result: { (localUrl) in

                    dicTemData.updateValue(localUrl?.path, forKey: "url")
                    dicTemData.updateValue("", forKey: "captionLabel")

                    downloadGroup.leave()
                })
            }
//            downloadGroup.wait()



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
//                        dicTemData.updateValue("", forKey: "captionLabel")
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
            downloadGroup.notify(queue: DispatchQueue.main) { // 2
//                DispatchQueue.main.async  {

//                    let tempParsedData = DataForAudioMessageInfoView(dict: dicTemData)
//                    contentViewCell?.dataForMediaInfoView = tempParsedData
                    contentViewCell?.setDataForMediaContentFromDictionary(dict: dicTemData)
                    self.messageModel?.dataForMediaInfoView = contentViewCell?.dataForMediaInfoView
                    contentViewCell?.spinner.stopAnimating()
                }
//            }
        }

    }



    //MARK:- UIView creation
    fileprivate func getPrepareXibOfEmbeddedView<Tview: UIView>(eraseExtraViews: Bool = true,
                                             xibName: String? = nil) -> Tview? {
        guard let masterContainer = self.previewContainer else {
            return nil
        }

        let xibNameForLoad = xibName ?? extraViewXibName

        let tryToReloadView:Bool = false //maybe, later it can be useful
        if tryToReloadView {
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
        } else {
            removeViewFromSuperView(view: masterContainer)
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

//        self.singleConversationControllerDelegate?.resizeSingleConversationCell(cell: self)

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

    func removeRequestedViewFromView<Tview: UIView>(view masterView: UIView,
                                      arrayOfRequestedViews: inout [Tview]) {

        for currentSubview in arrayOfRequestedViews {
            if let notNullIndexOfElement = arrayOfRequestedViews.index(of: currentSubview) {
                arrayOfRequestedViews.remove(at: notNullIndexOfElement)
            }

            currentSubview.removeFromSuperview()
        }
    }

    func removeRequestedViewFromView<Tview>(view masterView: UIView,
                                     typeOfRequestedView: Tview.Type) {
        let subviews = masterView.subviews

        for currentSubview in subviews {

            guard currentSubview is Tview else {
                continue
            }

            currentSubview.removeFromSuperview()
        }
    }

    func removeViewFromSuperView(view masterView: UIView) {
        let subviews = masterView.subviews

        for currentSubview in subviews {

//            guard currentSubview is UIView else {
//                continue
//            }

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
