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
    private var urlembedStrategy: RestUIStrategy

//    private var currentOrderId: Int

    private init() {
        urlembedStrategy = UrlParserFactory.urlparser(for: .urlembed)

//        self.currentOrderId = 0001
    }

//    func generateOrderForMechanic(mechanic: Mechanic, parts: [Part], carType: CarType) -> Order {
//        let orderId = currentOrderId + 1
//        let order = Order(orderId: orderId, parts: parts, carType: carType)
//        MechanicOrderDataProvider.instace.addMechanicOrder(order, mechanic: mechanic)
//        currentOrderId = orderId
//        return order
//    }

    func showData(dataForParse parsersData: RestUIStrategy) -> Bool {
        switch parsersData.strategyType {
        case .urlembed:
            return false//acmeStrategy.fulfillOrder(order)
        case .s500px:
            return false//partsnstuffStrategy.fulfillOrder(order)
//        case .European:
//            return autopartsStrategy.fulfillOrder(order)
        }
    }
}
