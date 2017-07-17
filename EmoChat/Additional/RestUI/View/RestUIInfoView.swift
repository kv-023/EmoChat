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

    var dataForRestUIInfoView: DataForRestUIInfoView? {
        didSet {
            if let notNullDataForRestUIInfoView = dataForRestUIInfoView {
                fullFillViewFromDataInfo(data: notNullDataForRestUIInfoView)
            }
        }
    }

    var heightOriginal:CGFloat = 0
    weak var dataModel: UrlembedModel?

    func fullFillViewFromDataInfo(data: DataForRestUIInfoView) {
        captionLabel.text = data.captionLabel
        detailLabel.text = data.detailLabel
        urlImageIco.image = data.urlImageIco
        mainImage.image = data.mainImage
        url = data.url
    }

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
        heightOriginal = self.bounds.height
    }
    
    private func addUrlTapRecognizer() {

        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                      action: #selector(handler))
        let tapRecognizer2 = UITapGestureRecognizer(target: self,
                                                   action: #selector(handler))
        captionLabel.addGestureRecognizer(tapRecognizer)
        detailLabel.addGestureRecognizer(tapRecognizer2)
    }

    func handler(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {

            let errorMessage1 = "an error occurred while open url:"
            guard let notNullURLString = self.url,
                let validUrl = URL(string: notNullURLString) else {
                    print(errorMessage1 + " \(String(describing: self.url))")
                    return
            }
            /*
            let sharedUIApplication = UIApplication.shared
            guard sharedUIApplication.canOpenURL(validUrl) else {
                print(errorMessage1 + " \(notNullURLString)")
                return
            }

            sharedUIApplication.open(validUrl, options: [:], completionHandler: nil)
            */
            
            let storyboard = UIStoryboard(name: "WebView", bundle: Bundle.main)
            let webVC = storyboard.instantiateViewController(withIdentifier: "WebVC") as! WebViewController
            webVC.url = validUrl
            
            var navController: UINavigationController?
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                // topController should now be your topmost view controller
                navController = topController as? UINavigationController
            }
            
            navController?.pushViewController(webVC, animated: true)
        }
    }

}
