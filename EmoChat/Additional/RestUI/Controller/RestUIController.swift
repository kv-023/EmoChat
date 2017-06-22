//
//  RestUIController.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

struct RestUIController: RegexCheckProtocol {

    static let sharedInstance = RestUIController()

    func testDataFirst() {
        let textDataForTest = "bla-bla bla https://9gag.com/gag/aRjwVVG bla-bla bla"


        let testFireBaseMessage = Message(uid: "0099887766545433",
                                          senderId: "id2222222Id",
                                          time: Date(),
                                          content: (type: MessageContentType.text, content: textDataForTest))
        let newModel = MessageModel(message: testFireBaseMessage)
        newModel.getParseDataFromResource()


//        let arrayOfLinks = getArrayOfRegexMatchesForURLInText(text: textDataForTest)
//
//        for urlLink in arrayOfLinks {
//
//            RestUIStrategyManager.instance.getDataFromURL(dataType: .urlembed,
//                                                          forUrl: urlLink) {
//                                                            (urlModel) in
//
//            }
//        }
    }
}

//        let textDataForTest = "bla-bla bla http://www.test.com/dir/filename.jpg?var1=foo#bar bla-bla blas https://urlembed.com/json  https://www.youtube.com/watch?v=1pHjCpJAU68 https://500px.com/photo/207156925/untitled-by-eivind-hansen?ctx_page=1&from=gallery&galleryPath=27297193&user_id=10599609"



//        RestUIStrategyManager.instance.getDataFromURL(dataForParse: RestUIUrlembed(),
//                                                      forUrl: "https://9gag.com/gag/aoOmXeA")

