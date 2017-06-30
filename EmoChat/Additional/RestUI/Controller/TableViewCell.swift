//
//  TableViewCell.swift
//  EmoChat
//
//  Created by Sergii Kyrychenko on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

protocol TestResizeCellInCell: class {
    //func resizeMyCell(cell: UITableViewCell)
}

class TableViewCell: UITableViewCell, TestResizeCellInCell {

    var testRDelegate:TestResizeCell?

    var messageModel: MessageModel?

    var message: Message? {
        didSet {
            parseDataFromMessageText()
        }
    }

    @IBOutlet weak var subViewREstHeight: NSLayoutConstraint!
    @IBOutlet weak var subViewRest: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var myImageInCell: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var myLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        subViewREstHeight.constant = 0
    }

    private func parseDataFromMessageText() {
        if let notNullMessage = message {
            let newModel = MessageModel(message: notNullMessage)
            newModel.getParseDataFromResource { (allDone) in
                if allDone {
                    self.messageModel = newModel

                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                }
            }
        }
    }

    private func updateUI() {
        spinner.startAnimating()

//        defer {
//            spinner.stopAnimating()
//        }

        let downloadGroup = DispatchGroup()

        guard let messageURLData = messageModel?.messageURLData else {
            return
        }

        for (key, value) in messageURLData {
            downloadGroup.enter()

            myLabel.text = key

            if let valueModel = value as? UrlembedModel {
                titleLabel.text = valueModel.title

                guard let notNullUrl = valueModel.url else {
                    continue
                }

                JSONParser.sharedInstance.downloadImage(url: notNullUrl) { (image) in
                    DispatchQueue.main.async  {
                        self.myImageInCell.image = image
                    }

                    downloadGroup.leave()
                }
            }
        }

        downloadGroup.notify(queue: DispatchQueue.main) { // 2
            DispatchQueue.main.async  {
                self.xibToFrameSetup()

                self.spinner.stopAnimating()
            }
        }
    }


    private func xibToFrameSetup() {

        let ccView = Bundle.main.loadNibNamed("RestUIInfo2",
                                              owner: self,
                                              options: nil)?.first as! RestUIInfoView
        let contentViewCell = ccView
        contentViewCell.captionLabel.text = "caption dsdsdsd "
        contentViewCell.detailLabel.text = "detail dsadsdd"
        contentViewCell.urlImageIco.image = UIImage(named: "mail-sent")

        let ccViewHeight = ccView.bounds.height
        contentViewCell.translatesAutoresizingMaskIntoConstraints = false

        contentViewCell.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.subViewRest.frame.width,
                                       height: ccViewHeight)


        self.subViewREstHeight.constant = ccViewHeight
        self.subViewRest.addSubview(contentViewCell)


        setConstrainInSubView(embeddedView: contentViewCell, parrentView: self.subViewRest)
        self.subViewRest.layoutIfNeeded()


        self.testRDelegate?.resizeMyCell(cell: self)

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
