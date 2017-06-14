//
//  EmoChatUIViewController.swift
//  CustomTextFieldEmoChat
//
//  Created by Nikolay Dementiev on 13.06.17.
//  Copyright © 2017 mc373. All rights reserved.
//

//Superclass for all instances which have to use PopOveIo box in textField

import UIKit

class EmoChatUIViewController: UIViewController {

}

extension EmoChatUIViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
