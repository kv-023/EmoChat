//
//  RegExpControll.swift
//  EmoChat
//
//  Created by Andrii Tkachuk on 6/6/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//
//look for: http://benscheirman.com/2014/06/regex-in-swift/


import Foundation

struct Regex {

    private static func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex,
                                                options:[.caseInsensitive])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                        range: NSRange(location: 0, length: nsString.length))

            return results.map { nsString.substring(with: $0.range) }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")

            return []
        }
    }

    static func isMatchInString(for regex: String, in text: String) -> Bool {

        return  Regex.matches(for: regex, in: text).count > 0
    }

    static func getMatchesInString(for regex: String, in text: String) -> [String] {

        return  Regex.matches(for: regex, in: text)
    }

    static func removingRegexMatches(for regex: String,
                                     in text: String,
                                     replaceWith: String = "") -> String? {
        var valueForReturn: String?
        do {
            let regex = try NSRegularExpression(pattern: regex,
                                                options:[.caseInsensitive])
            let range = NSMakeRange(0, text.characters.count)
            valueForReturn = regex.stringByReplacingMatches(in: text,
                                                            options: [],
                                                            range: range,
                                                            withTemplate: replaceWith)
        } catch {
            print("invalid regex: \(error.localizedDescription)")
            return valueForReturn
        }
        return valueForReturn
    }
    
}
