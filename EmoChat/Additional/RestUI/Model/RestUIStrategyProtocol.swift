//
//  RestUIStrategyProtocol.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//


protocol RestUIStrategy {
    var strategyType: UrlParserResourseType {get}

    func showData(_ string: String) -> String
}

//MARK: data type
enum UrlParserResourseType: Int {
    case urlembed = 0, s500px
}

