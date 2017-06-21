//
//  UIImageViewExtension.swift
//  EmoChat
//
//  Created by Igor Demchenko on 6/20/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

extension UIImageView {
	
	public func loadGif(name: String) {
		
		DispatchQueue.global().async {
			
			let image = UIImage.gif(name: name)
			DispatchQueue.main.async {
				self.image = image
			}
			
		}
		
	}
	
}
