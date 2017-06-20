//
//  DateExtension.swift
//  EmoChat
//
//  Created by Admin on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000.0))
    }
}
