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

    init() {
        self.strategyType = UrlParserResourseType.s500px
    }

    //RestUIStrategy's protocol implementation
    func showData(_ string: String) -> String {
        return ""
    }
}
