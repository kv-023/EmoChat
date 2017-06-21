//
//  RestIU500px.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

final class RestIU500px : RestUIStrategy {
    var strategyType: UrlParserResourseType
    var httpAdress:String
    var apiKey:String

    init() {
        self.strategyType = UrlParserResourseType.s500px
        self.httpAdress = ""
        self.apiKey = ""
    }

    //RestUIStrategy's protocol implementation
    func getData(forUrl urlResource:String) -> String {
        return ""
    }

    func getLinkForResponse(forUrl urlResource:String) -> String {
        return "<null data>"
    }
}
