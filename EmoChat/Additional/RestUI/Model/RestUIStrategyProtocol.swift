//
//  RestUIStrategyProtocol.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//


protocol RestUIStrategy {
    var strategyType: UrlParserResourseType {get}
    var apiKey:String {get}
    var httpAdress:String {get}

    func getData(forUrl urlResource:String) -> String
    func getLinkForResponse(forUrl urlResource:String) -> String
}

//MARK: data type
enum UrlParserResourseType: Int {
    case urlembed = 0, s500px
}

