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

    //nik 2017-07-29
    func shrinkText(maxAllowableLength maxLength: Int = 30,
                    fillerSpaceBetween filler: String = "<...>") -> String {

        let mediana: Int = (maxLength - filler.count) / 2
        let firstSymbol = String(prefix(mediana))
        let lastSymbol = String(suffix(mediana))
        let textShrinked: String = "☞" + firstSymbol + filler + lastSymbol

        return textShrinked

    }

}

//nik 2017-07-29
extension String: RegexCheckProtocol {

    mutating func shrinkUrlAddress(maxAllowableLength maxLength: Int = 25,
                                   fillerSpaceBetween filler: String = "<...>") {

        var newString: String = self
        if newString.count > maxLength {

            let arrayOfLinks = self.getArrayOfRegexMatchesForURLInText(text: newString)

            if arrayOfLinks.count > 0 {
                for urlInText in arrayOfLinks {
                    let urlInTextWithOutTag = self.removeTransferProtocolTag(text: urlInText)
                    let shrinkedUrl = urlInTextWithOutTag.shrinkText(maxAllowableLength: maxLength,
                                                 fillerSpaceBetween: filler)

                    newString = newString.replacingOccurrences(of: urlInText, with: shrinkedUrl)
                }
            }
        }
        
        if self.count > newString.count {
            self = newString
        }
    }
}
