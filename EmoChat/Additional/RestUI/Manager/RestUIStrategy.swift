//
//  RestUIStrategy.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class RestUIStrategyManager {

    static var instance = RestUIStrategyManager()

//    private lazy var urlembedStrategy: RestUIStrategy = {
//        return UrlParserFactory.urlparser(for: .urlembed)
//    }()
    
    private var urlembedStrategy: RestUIStrategy
    
    private init() {
        urlembedStrategy = UrlParserFactory.urlparser(for: .urlembed)
    }

    func getDataFromURL(dataType parsersDataType: UrlParserResourseType,
                        forUrl urlForRequest:String,
                        completion:@escaping CompletionModel) {
        switch parsersDataType {
        case .urlembed:
            urlembedStrategy.getData(forUrl: urlForRequest) {
                (urlModel) in

                completion(urlModel)
            }
        }
    }
}


//MARK: Factory method
private enum UrlParserFactory {
    static func urlparser(for parserType:UrlParserResourseType) -> RestUIStrategy {
        switch parserType {
        case .urlembed :
            return RestUIUrlembed()
        }
    }
}
