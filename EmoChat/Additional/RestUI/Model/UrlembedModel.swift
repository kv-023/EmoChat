//
//  UrlembedModel.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 21.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

final class UrlembedModel {

    var type: String?
    var language: String?
    var favicon: String?
    var provider_name: String?
    var title: String?
    var description: String?
    var url: String?
    var height: Int?
    var width: Int?
    var html: String?
    var content: String?
    var text: String?
    var keywords: [String]?
    var links: [String]?
    var date: Float?
    var version: Float?

    init(json jsonData: JsonDataType) {
         type = jsonData["type"] as? String
         language = jsonData["language"] as? String
         favicon = jsonData["favicon"] as? String
         provider_name = jsonData["provider_name"] as? String
         title = jsonData["title"] as? String
         description = jsonData["description"] as? String
         url = jsonData["url"] as? String
         height = jsonData["height"] as? Int
         width = jsonData["width"] as? Int
         html = jsonData["html"] as? String
         content = jsonData["content"] as? String
         text = jsonData["text"] as? String
         keywords = getaJsonDataFromArray(data: jsonData["keywords"] as? [JsonDataType])
         links = getaJsonDataFromArray(data: jsonData["links"] as? [JsonDataType])
         date = jsonData["date"] as? Float
         version = jsonData["version"] as? Float
    }

    private func getaJsonDataFromArray(data jsonData: [JsonDataType]?) -> [String]? {
        var arrayForReturn: [String] = []

        if let notNullJsonData = jsonData {
            for itemInArray in notNullJsonData {
                //arrayForReturn.append((itemInArray ?? "") as? String)
            }
        }

        return arrayForReturn
    }
}
