//
//  CustomTextField2.swift
//  CustomTextFieldEmoChat
//
//  Created by Nikolay Dementiev on 08.06.17.
//  Copyright © 2017 mc373. All rights reserved.
//
//https://stackoverflow.com/a/42082398/6643923

import UIKit

//@IBDesignable
class CustomTextFieldWithPopOverInfoBox: UITextField {

    private lazy var dataContainer = {
        return HelperForCustomTextFieldWithPopOverInfoBox()
    }()

    var image: UIImage?
    var btnQuestion:UIButton?
    var textInfoForQuestionLabel: String? {
        didSet {
            
        }
    }
    var popOverVC: PopOverViewController?

    var imageQuestionShowed: Bool = false {
        didSet {
            hideOrShowImageQuestion()
        }
    }

    var imgLeftInset: CGFloat = 0
    var imgTopInset: CGFloat = 0
    var imgBottomInset: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    //MARK: question mark button
    @objc func commonInit() {
        clipsToBounds = true

        textInfoForQuestionLabel = "smth went wrong..."

        popOverVC = Bundle.main.loadNibNamed("PopOverVC", owner: self, options: nil)?[0] as? PopOverViewController

        imgLeftInset = dataContainer.imgLeftInset
        imgTopInset = dataContainer.imgTopInset
        imgBottomInset = dataContainer.imgBottomInset

        image = dataContainer.questionImage

        let weight = self.bounds.height - (imgTopInset + imgBottomInset)

        btnQuestion = UIButton(type: .custom)
        if let notNullQuestionBtn = btnQuestion{
            notNullQuestionBtn.addTarget(self,
                                         action: #selector(self.openPopOverVC),
                                         for: .touchUpInside)
            notNullQuestionBtn.frame = CGRect(x: imgLeftInset,
                                              y: imgTopInset,
                                              width: weight,
                                              height: weight)
            notNullQuestionBtn.setBackgroundImage(image, for: .normal)
        }

        leftView = btnQuestion

        hideQuestionImage()
    }

    func hideOrShowImageQuestion() {
        if !imageQuestionShowed {
            //hide it
            hideQuestionImage()
            whiteBorder()
        } else {
            //show it
            showQuestionImage()
            redBorder()
        }
    }

    func showQuestionImage() {

        leftViewMode = .always
    }

    func hideQuestionImage() {

        self.leftViewMode = .never
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {

        var textRect:CGRect  = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += imgLeftInset

        return textRect;
    }

    //MARK: popOverWindow

    @objc func openPopOverVC() {

        if  let vcPopOver = popOverVC {

            if let notNullVCOwner:CorrectUIVC = firstAvailableUIViewController() {

                // Present the view controller using the popover style.
                vcPopOver.modalPresentationStyle = .popover
                // vcPopOver.preferredContentSize = self.bounds.size
                let summOfAllHorizontalCanstraints = 20 // you can find it in "PopOverVC.xib"
                let widthForFrameRect = self.bounds.width
                vcPopOver.preferredContentSize = CGSize(width: widthForFrameRect,
                                                        height: textHeight(text: textInfoForQuestionLabel,
                                                                           maxWidth: widthForFrameRect - CGFloat(summOfAllHorizontalCanstraints)))

                vcPopOver.infoLabelText = textInfoForQuestionLabel

                vcPopOver.view.backgroundColor = dataContainer.popOverVCBackgroundColor

                if let notNullBtnQuestion = btnQuestion,
                    let popoverPresentationController = vcPopOver.popoverPresentController {

                    popoverPresentationController.sourceView = notNullBtnQuestion
                    popoverPresentationController.sourceRect = notNullBtnQuestion.bounds
                    popoverPresentationController.permittedArrowDirections = .down//.any
                    popoverPresentationController.delegate = notNullVCOwner
                    popoverPresentationController.backgroundColor = dataContainer.popOverCOntrollerBackgroundColor

                }

                notNullVCOwner.present(vcPopOver, animated: true, completion: nil)
            }
        }
    }

    private func textHeight(text: String?, maxWidth: CGFloat = 200) -> CGFloat {
        let minimumTextHeight: CGFloat = 25
        var textHeight: CGFloat = minimumTextHeight

        if let notNullText = text {
            let rect: CGRect = notNullText.boundingRect(with:
                CGSize(width: maxWidth, height:CGFloat.greatestFiniteMagnitude),
                                                        options: ([.usesLineFragmentOrigin, .usesFontLeading]),
                                                        attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "Arial", size: 16) ?? 15]),
                                                        context: nil)

            textHeight = max(rect.size.height + 5, minimumTextHeight)
        }

        return textHeight
    }


    @objc override func redBorder() {
        super.redBorder()

       // shake()
    }

	//MARK: Shake animation inplementation
	
	func shake() {
		shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
	}
	
	func shake(myDelay: Double) {
		shake(count: 1, for: 0.05, withTranslation: 15, delay: myDelay)
	}
	
	func shake(count : Float? = nil,
	           for duration : TimeInterval? = nil,
	           withTranslation translation : Float? = nil, delay: Double) {
		let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
		animation.beginTime = CACurrentMediaTime() + delay
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
		animation.repeatCount = count ?? 2
		animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
		animation.autoreverses = true
		animation.byValue = translation ?? -5
		layer.add(animation, forKey: "shake")
	}
}

//MARK: data structure
fileprivate struct HelperForCustomTextFieldWithPopOverInfoBox {
    //http://colorhunt.co/c/71302
    let popOverVCBackgroundColor:UIColor = UIColor(red: 255,green: 211,blue: 182)
    let popOverCOntrollerBackgroundColor:UIColor = UIColor(red: 255,green: 170,blue: 165)
    let textColorPopOver:UIColor = UIColor.black
    
    let imgLeftInset: CGFloat = 5.0
    let imgTopInset: CGFloat = 3.0
    let imgBottomInset: CGFloat = 3.0
    
    let questionImage = UIImage(named: "question")
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
