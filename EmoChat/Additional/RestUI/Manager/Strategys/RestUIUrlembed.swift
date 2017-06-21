//
//  RestIU-Urlembed.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

final class RestUIUrlembed: RestUIStrategy {
    var strategyType: UrlParserResourseType
    var httpAdress:String
    var apiKey:String

    init() {
        self.strategyType = UrlParserResourseType.urlembed
        self.apiKey = "WDYyREZLSlU2TUk0Qlk2V0xMUklYM01JS0M1VUxJREZXVDZMUU1IQ0tXREhCN0s1TURGQT09PT0"
        self.httpAdress = "https://urlembed.com/json"
    }

//    convenience init(forUrl urlResource:String) {
//
//    }

    func getJsonData(forUrl urlResource:String) {
        let urlForConnect = getLinkForResponse(forUrl: urlResource)
        JSONParser.sharedInstance.getJSONDataFromURL(forUrl: urlForConnect) {
            (jsonData: JsonDataType?) in
            if let notNullJsonData = jsonData {
                let urlModel = UrlembedModel(json: notNullJsonData)
            }
        }
    }

    //RestUIStrategy's protocol implementation
    func getData(forUrl urlResource:String) -> String {
        getJsonData(forUrl: urlResource)

        return ""
    }

    func getLinkForResponse(forUrl urlResource:String) -> String {
        let backSlashString = "/"


//        return "\(httpAdress+backSlashString)\(apiKey+backSlashString)\(urlResource)"
        return String(httpAdress+backSlashString+apiKey+backSlashString+urlResource)
    }
}
