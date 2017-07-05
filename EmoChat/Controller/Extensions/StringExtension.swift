//
//  StringExtension.swift
//  EmoChat
//
//  Created by Igor Demchenko on 7/5/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

extension String {

	func getPathExtension() -> String {
		return (self as NSString).pathExtension
	}

}
