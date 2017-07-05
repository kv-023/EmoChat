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
        return Int((self.timeIntervalSince1970 * 1000).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    func formatDate() -> String {
        let dataformatter = DateFormatter.init()
        dataformatter.timeStyle = .short
        let date = dataformatter.string(from: self)
        return date
    }
    
    func dayFormatStyle() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.MM.yy"
        let date = dateFormatter.string(from: self)
        return date
    }
    
}   
