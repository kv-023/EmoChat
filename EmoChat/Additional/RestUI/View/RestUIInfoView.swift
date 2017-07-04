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

    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)

        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)

        self.commonInit()
    }

    override func awakeFromNib() {
        addUrlTapRecognizer()
    }

    private func commonInit() {

    }
    
    private func addUrlTapRecognizer() {

        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                      action: #selector(handler))
        captionLabel.addGestureRecognizer(tapRecognizer)
        detailLabel.addGestureRecognizer(tapRecognizer)
    }

    func handler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {

            let errorMessage1 = "an error occurred while open url:"
            guard let notNullURLString = self.url,
                let validUrl = URL(string: notNullURLString) else {
                    print(errorMessage1 + " \(String(describing: self.url))")
                    return
            }

            let sharedUIApplication = UIApplication.shared
            guard sharedUIApplication.canOpenURL(validUrl) else {
                print(errorMessage1 + " \(notNullURLString)")
                return
            }

            sharedUIApplication.open(validUrl, options: [:], completionHandler: nil)

        }
    }

}
