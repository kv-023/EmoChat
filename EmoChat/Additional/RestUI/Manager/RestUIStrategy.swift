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

//    private var currentOrderId: Int

    private init() {
//        urlembedStrategy = UrlParserFactory.urlparser(for: .urlembed)

//        self.currentOrderId = 0001
    }

//    func generateOrderForMechanic(mechanic: Mechanic, parts: [Part], carType: CarType) -> Order {
//        let orderId = currentOrderId + 1
//        let order = Order(orderId: orderId, parts: parts, carType: carType)
//        MechanicOrderDataProvider.instace.addMechanicOrder(order, mechanic: mechanic)
//        currentOrderId = orderId
//        return order
//    }

    func getDataFromURL(dataForParse parsersData: RestUIStrategy,
                        forUrl urlForRequest:String) -> Bool {
        switch parsersData.strategyType {
        case .urlembed:
            let RRR = parsersData.getData(forUrl: urlForRequest)
            return false
        case .s500px:
            return false//partsnstuffStrategy.fulfillOrder(order)
//        case .European:
//            return autopartsStrategy.fulfillOrder(order)
        }
    }
}


////MARK: Factory method
//enum UrlParserFactory {
//    static func urlparser(for perserType:UrlParserResourseType) -> RestUIStrategy {
//        switch perserType {
//        case .urlembed :
//            return RestUIUrlembed()
//        case .s500px :
//            return RestIU500px()
//            //        default:
//            //            return nil
//        }
//    }
//}
