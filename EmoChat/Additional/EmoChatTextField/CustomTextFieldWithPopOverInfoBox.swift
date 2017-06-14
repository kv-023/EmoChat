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
    var textInfoForQuestionLabel: String?
    var popOverVC: PopOverViewController?

    //    @IBInspectable
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
    private func commonInit() {
        clipsToBounds = true

        popOverVC = Bundle.main.loadNibNamed("PopOverVC", owner: self, options: nil)?[0] as? PopOverViewController

        imgLeftInset = dataContainer.imgLeftInset
        imgTopInset = dataContainer.imgTopInset
        imgBottomInset = dataContainer.imgBottomInset

        image = dataContainer.questionImage//UIImage(named: "question")

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

        hideOrShowImageQuestion()
    }

    func hideOrShowImageQuestion() {
        if imageQuestionShowed {
            //hide it
            hideQuestionImage()
        } else {
            //show it
            showQuestionImage()
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

    func openPopOverVC() {
        //        if  let vcPopOver = UIStoryboard(name: "PopOverView", bundle: nil).instantiateViewController(withIdentifier: "popoverViewController") as? PopUpViewController {

        if  let vcPopOver = popOverVC {

            if let notNullVCOwner:CorrectUIVC = firstAvailableUIViewController() {

                // Present the view controller using the popover style.
                vcPopOver.modalPresentationStyle = .popover
                vcPopOver.preferredContentSize = self.bounds.size
                //CGSize(width: 50, height: 50)

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

}

//MARK:- Spec. controller's behavior

////MARK: Shake animation inplementation
//func shake(count : Float? = nil, for duration : TimeInterval? = nil, withTranslation translation : Float? = nil) {
//    let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
//    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
//    animation.repeatCount = count ?? 2
//    animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
//    animation.autoreverses = true
//    animation.byValue = translation ?? -5
//    layer.add(animation, forKey: "shake")
//}

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
