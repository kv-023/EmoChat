//
//  modelGenericHelper.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 01.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

typealias linkedTableType = [String: Bool]

protocol FireBaseEmoChat {

    var uuid: String {get set}
//    func collectDataFromModelInstance() -> linkedTableType

}

extension FireBaseEmoChat {

    var uuid: String {
        return getEmpyUUID()
    }

    func getEmpyUUID() -> String {
        return Auxiliary.getEmpyUUID()
    }

    func collectDataFromModelInstance (_ dataInArray: [FireBaseEmoChat?]?) -> linkedTableType {
        var tempArrayData = linkedTableType()

        if let notNullDataInInstance = dataInArray {
            for itemInArray in notNullDataInInstance {
                if let notNullDataInInstance = itemInArray {
                    tempArrayData.updateValue(true,
                                              forKey: notNullDataInInstance.uuid)
                }
            }
        }
        return tempArrayData
        
    }

}
