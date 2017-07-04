//
//  RestUIInfoView.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 25.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class RestUIInfoView: UIView {

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var urlImageIco: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var url: String?
    weak var dataModel: UrlembedModel?

    func eraseAllFields() {
        captionLabel.text = ""
        detailLabel.text = ""
        urlImageIco.image = UIImage()
        mainImage.image = UIImage()
    }
}
