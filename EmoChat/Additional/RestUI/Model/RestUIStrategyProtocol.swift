//
//  RestUIStrategyProtocol.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

//import Foundation

protocol RestUIStrategy {
    var strategyType: UrlParserResourseType {get set}

    func showData(_ string: String) -> String
}

//MARK: data type
enum UrlParserResourseType: Int {
    case urlembed = 0, s500px
}

//MARK: Factory method
enum UrlParserFactory {
    static func urlparser(for perserType:UrlParserResourseType) -> RestUIStrategy {
        switch perserType {
        case .urlembed :
            return RestIUUrlembed()
        case .s500px :
            return RestIU500px()
//        default:
//            return nil
        }
    }
}
