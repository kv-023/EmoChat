//
//  AdditionalCellView.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 29.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class AdditionalCellView: UIView {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var captionLabel: UILabel!
    var url: String?
    var dataForMediaInfoView: DataForMediaMessageInfoProtocol?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func fullFillViewFromDataInfo(data: DataForMediaMessageInfoProtocol) {
        captionLabel.text = data.captionLabel
        url = data.url
    }

    func eraseAllFields() {
        captionLabel.text = ""
        url = ""
    }

    func setDataForMediaContentFromDictionary(dict: [String: Any?]) {

    }

}
